#ifndef SCUMWM_SHIM_H
#define SCUMWM_SHIM_H

#ifndef WLR_USE_UNSTABLE
#define WLR_USE_UNSTABLE
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

void shim_output_set_mode(struct wlr_output *output, struct wlr_output_mode *mode);
void shim_output_enable(struct wlr_output *output, bool enable);
bool shim_output_commit(struct wlr_output *output);
bool shim_output_attach_render(struct wlr_output *output, int *buffer_age);
void shim_renderer_begin(struct wlr_renderer *renderer, int width, int height);
void shim_renderer_end(struct wlr_renderer *renderer);
void shim_renderer_clear(struct wlr_renderer *renderer, const float color[4]);
void shim_scene_render_output(struct wlr_scene *scene, struct wlr_output *output,
		const struct timespec *now);
struct wlr_scene_tree *shim_scene_get_root(struct wlr_scene *scene);
struct wlr_xdg_toplevel *shim_xdg_surface_get_toplevel(struct wlr_xdg_surface *surface);

#endif
