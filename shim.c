#include "shim.h"

#include <stdlib.h>

struct shim_new_output_listener {
	struct wl_listener listener;
	void *userdata;
	void (*cb)(void *userdata, struct wlr_output *output);
};

struct shim_new_xdg_surface_listener {
	struct wl_listener listener;
	void *userdata;
	void (*cb)(void *userdata, struct wlr_xdg_surface *surface);
};

struct shim_output_frame_listener {
	struct wl_listener listener;
	void *userdata;
	void (*cb)(void *userdata, struct wlr_output *output);
};

static void shim_handle_new_output(struct wl_listener *listener, void *data) {
	struct shim_new_output_listener *shim =
		wl_container_of(listener, shim, listener);
	shim->cb(shim->userdata, data);
}

static void shim_handle_new_xdg_surface(struct wl_listener *listener, void *data) {
	struct shim_new_xdg_surface_listener *shim =
		wl_container_of(listener, shim, listener);
	shim->cb(shim->userdata, data);
}

static void shim_handle_output_frame(struct wl_listener *listener, void *data) {
	struct shim_output_frame_listener *shim =
		wl_container_of(listener, shim, listener);
	shim->cb(shim->userdata, data);
}

void shim_register_new_output_listener(struct wlr_backend *backend, void *userdata,
		void (*cb)(void *userdata, struct wlr_output *output)) {
	struct shim_new_output_listener *shim = calloc(1, sizeof(*shim));
	if (shim == NULL) {
		return;
	}
	shim->userdata = userdata;
	shim->cb = cb;
	shim->listener.notify = shim_handle_new_output;
	wl_signal_add(&backend->events.new_output, &shim->listener);
}

void shim_register_new_xdg_surface_listener(struct wlr_xdg_shell *xdg_shell, void *userdata,
		void (*cb)(void *userdata, struct wlr_xdg_surface *surface)) {
	struct shim_new_xdg_surface_listener *shim = calloc(1, sizeof(*shim));
	if (shim == NULL) {
		return;
	}
	shim->userdata = userdata;
	shim->cb = cb;
	shim->listener.notify = shim_handle_new_xdg_surface;
	wl_signal_add(&xdg_shell->events.new_surface, &shim->listener);
}

void shim_register_output_frame_listener(struct wlr_output *output, void *userdata,
		void (*cb)(void *userdata, struct wlr_output *output)) {
	struct shim_output_frame_listener *shim = calloc(1, sizeof(*shim));
	if (shim == NULL) {
		return;
	}
	shim->userdata = userdata;
	shim->cb = cb;
	shim->listener.notify = shim_handle_output_frame;
	wl_signal_add(&output->events.frame, &shim->listener);
}

struct wlr_scene_node *shim_scene_xdg_surface_create_node(
    struct wlr_scene_tree *parent,
    struct wlr_xdg_surface *surface) {
    if (parent == NULL || surface == NULL) {
        return NULL;
    }

    struct wlr_scene_tree *tree = wlr_scene_xdg_surface_create(parent, surface);
    if (tree == NULL) {
        return NULL;
    }

    return &tree->node;
}

void shim_scene_node_set_position(struct wlr_scene_node *node, int x, int y) {
	if (node == NULL) {
		return;
	}
	wlr_scene_node_set_position(node, x, y);
}

void shim_output_set_mode(struct wlr_output *output, struct wlr_output_mode *mode) {
	if (output == NULL || mode == NULL) {
		return;
	}
	wlr_output_set_mode(output, mode);
}

void shim_output_enable(struct wlr_output *output, bool enable) {
	if (output == NULL) {
		return;
	}
	wlr_output_enable(output, enable);
}

bool shim_output_commit(struct wlr_output *output) {
	if (output == NULL) {
		return false;
	}
	return wlr_output_commit(output);
}

bool shim_output_attach_render(struct wlr_output *output, int *buffer_age) {
	if (output == NULL) {
		return false;
	}
	return wlr_output_attach_render(output, buffer_age);
}

void shim_renderer_begin(struct wlr_renderer *renderer, int width, int height) {
	if (renderer == NULL) {
		return;
	}
	wlr_renderer_begin(renderer, width, height);
}

void shim_renderer_end(struct wlr_renderer *renderer) {
	if (renderer == NULL) {
		return;
	}
	wlr_renderer_end(renderer);
}

void shim_renderer_clear(struct wlr_renderer *renderer, const float color[4]) {
	if (renderer == NULL || color == NULL) {
		return;
	}
	wlr_renderer_clear(renderer, color);
}

void shim_scene_render_output(struct wlr_scene *scene, struct wlr_output *output,
		const struct timespec *now) {
	if (scene == NULL || output == NULL) {
		return;
	}
	wlr_scene_render_output(scene, output, now);
}

struct wlr_scene_tree *shim_scene_get_root(struct wlr_scene *scene) {
	if (scene == NULL) {
		return NULL;
	}
	return wlr_scene_get_root(scene);
}

struct wlr_xdg_toplevel *shim_xdg_surface_get_toplevel(struct wlr_xdg_surface *surface) {
	if (surface == NULL) {
		return NULL;
	}
	return wlr_xdg_surface_get_toplevel(surface);
}
