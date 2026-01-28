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

void shim_scene_xdg_surface_set_position(struct wlr_scene_xdg_surface *scene, int x, int y) {
	if (scene == NULL) {
		return;
	}
	wlr_scene_node_set_position(&scene->tree->node, x, y);
}
