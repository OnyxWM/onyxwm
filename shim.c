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

struct wlr_compositor *shim_compositor_create(struct wl_display *display,
		struct wlr_renderer *renderer) {
	if (display == NULL) {
		return NULL;
	}
	return wlr_compositor_create(display, 4, renderer);
}

struct wlr_xdg_shell *shim_xdg_shell_create(struct wl_display *display) {
	if (display == NULL) {
		return NULL;
	}
	return wlr_xdg_shell_create(display, 1);
}

bool shim_output_configure(struct wlr_output *output, struct wlr_output_mode *mode,
		bool enable) {
	if (output == NULL) {
		return false;
	}

	struct wlr_output_state state;
	wlr_output_state_init(&state);
	wlr_output_state_set_enabled(&state, enable);
	if (mode != NULL) {
		wlr_output_state_set_mode(&state, mode);
	}
	bool ok = wlr_output_commit_state(output, &state);
	wlr_output_state_finish(&state);
	return ok;
}

bool shim_scene_output_commit(struct wlr_scene_output *scene_output) {
	if (scene_output == NULL) {
		return false;
	}
	struct wlr_scene_output_state_options options = {0};
	return wlr_scene_output_commit(scene_output, &options);
}

struct wlr_scene_tree *shim_scene_get_root(struct wlr_scene *scene) {
	if (scene == NULL) {
		return NULL;
	}
	return &scene->tree;
}

bool shim_xdg_surface_is_toplevel(struct wlr_xdg_surface *surface) {
	if (surface == NULL) {
		return false;
	}
	return surface->role == WLR_XDG_SURFACE_ROLE_TOPLEVEL;
}
