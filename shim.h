#ifndef SCUMWM_SHIM_H
#define SCUMWM_SHIM_H

#ifndef WLR_USE_UNSTABLE
#define WLR_USE_UNSTABLE 1
#endif

#include <stdbool.h>
#include <time.h>

#include <wayland-server-core.h>
#include <wlr/backend.h>
#include <wlr/types/wlr_output.h>
#include <wlr/types/wlr_xdg_shell.h>
#include <wlr/types/wlr_scene.h>

void shim_register_new_output_listener(struct wlr_backend *backend, void *userdata,
		void (*cb)(void *userdata, struct wlr_output *output));

void shim_register_new_xdg_surface_listener(struct wlr_xdg_shell *xdg_shell, void *userdata,
		void (*cb)(void *userdata, struct wlr_xdg_surface *surface));

void shim_register_output_frame_listener(struct wlr_output *output, void *userdata,
		void (*cb)(void *userdata, struct wlr_output *output));

struct wlr_scene_node *shim_scene_xdg_surface_create_node(
		struct wlr_scene_tree *parent,
		struct wlr_xdg_surface *surface);

void shim_scene_node_set_position(struct wlr_scene_node *node, int x, int y);

bool shim_output_configure(struct wlr_output *output, struct wlr_output_mode *mode,
		bool enable);
bool shim_scene_output_commit(struct wlr_scene_output *scene_output);
struct wlr_scene_tree *shim_scene_get_root(struct wlr_scene *scene);
bool shim_xdg_surface_is_toplevel(struct wlr_xdg_surface *surface);

#endif
