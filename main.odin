package main

wl_display :: struct {}
wlr_backend :: struct {}
wlr_renderer :: struct {}
wlr_allocator :: struct {}
wlr_compositor :: struct {}
wlr_subcompositor :: struct {}
wlr_data_device_manager :: struct {}
wlr_output_layout :: struct {}
wlr_scene :: struct {}
wlr_scene_output_layout :: struct {}
wlr_xdg_shell :: struct {}
wlr_seat :: struct {}
wlr_output :: struct {}
wlr_xdg_surface :: struct {}
wlr_output_mode :: struct {}
wlr_output_layout_output :: struct {}
wlr_scene_output :: struct {}
wlr_scene_tree :: struct {}
wlr_scene_node :: struct {}
wlr_scene_xdg_surface :: struct {}
wlr_xdg_toplevel :: struct {}

foreign import wayland "system:wayland-server"
foreign import wlroots "system:wlroots"
foreign import shim "shim"

foreign wayland {
	wl_display_create  :: proc() -> ^wl_display ---
	wl_display_destroy :: proc(display: ^wl_display) ---
	wl_display_run     :: proc(display: ^wl_display) ---
}

foreign wlroots {
	wlr_backend_autocreate :: proc(display: ^wl_display) -> ^wlr_backend ---
	wlr_renderer_autocreate :: proc(backend: ^wlr_backend) -> ^wlr_renderer ---
	wlr_allocator_autocreate :: proc(backend: ^wlr_backend, renderer: ^wlr_renderer) -> ^wlr_allocator ---
	wlr_compositor_create :: proc(display: ^wl_display, renderer: ^wlr_renderer) -> ^wlr_compositor ---
	wlr_subcompositor_create :: proc(display: ^wl_display) -> ^wlr_subcompositor ---
	wlr_data_device_manager_create :: proc(display: ^wl_display) -> ^wlr_data_device_manager ---
	wlr_output_layout_create :: proc() -> ^wlr_output_layout ---
	wlr_scene_create :: proc() -> ^wlr_scene ---
	wlr_scene_attach_output_layout :: proc(scene: ^wlr_scene, layout: ^wlr_output_layout) -> ^wlr_scene_output_layout ---
	wlr_xdg_shell_create :: proc(display: ^wl_display) -> ^wlr_xdg_shell ---
	wlr_seat_create :: proc(display: ^wl_display, name: cstring) -> ^wlr_seat ---
	wlr_backend_start :: proc(backend: ^wlr_backend) -> bool ---
	wlr_output_preferred_mode :: proc(output: ^wlr_output) -> ^wlr_output_mode ---
	wlr_output_set_mode :: proc(output: ^wlr_output, mode: ^wlr_output_mode) ---
	wlr_output_enable :: proc(output: ^wlr_output, enable: bool) ---
	wlr_output_commit :: proc(output: ^wlr_output) -> bool ---
	wlr_output_layout_add_auto :: proc(layout: ^wlr_output_layout, output: ^wlr_output) -> ^wlr_output_layout_output ---
	wlr_scene_output_create :: proc(scene: ^wlr_scene, output: ^wlr_output) -> ^wlr_scene_output ---
	wlr_scene_output_layout_add_output :: proc(scene_layout: ^wlr_scene_output_layout, layout_output: ^wlr_output_layout_output, scene_output: ^wlr_scene_output) ---
	wlr_output_attach_render :: proc(output: ^wlr_output, buffer_age: ^int) -> bool ---
	wlr_output_effective_resolution :: proc(output: ^wlr_output, width: ^int, height: ^int) ---
	wlr_renderer_begin :: proc(renderer: ^wlr_renderer, width: int, height: int) ---
	wlr_renderer_end :: proc(renderer: ^wlr_renderer) ---
	wlr_renderer_clear :: proc(renderer: ^wlr_renderer, color: ^[4]f32) ---
	wlr_scene_render_output :: proc(scene: ^wlr_scene, output: ^wlr_output, now: ^timespec) ---
	wlr_scene_get_root :: proc(scene: ^wlr_scene) -> ^wlr_scene_tree ---
	wlr_scene_xdg_surface_create :: proc(parent: ^wlr_scene_tree, surface: ^wlr_xdg_surface) -> ^wlr_scene_xdg_surface ---
	wlr_scene_node_set_position :: proc(node: ^wlr_scene_node, x: int, y: int) ---
	wlr_xdg_surface_get_toplevel :: proc(surface: ^wlr_xdg_surface) -> ^wlr_xdg_toplevel ---
}

NewOutputCallback :: proc "c" (userdata: rawptr, output: ^wlr_output)
NewXdgSurfaceCallback :: proc "c" (userdata: rawptr, surface: ^wlr_xdg_surface)
OutputFrameCallback :: proc "c" (userdata: rawptr, output: ^wlr_output)

foreign shim {
	shim_register_new_output_listener :: proc(backend: ^wlr_backend, userdata: rawptr, cb: NewOutputCallback) ---
	shim_register_new_xdg_surface_listener :: proc(xdg_shell: ^wlr_xdg_shell, userdata: rawptr, cb: NewXdgSurfaceCallback) ---
	shim_register_output_frame_listener :: proc(output: ^wlr_output, userdata: rawptr, cb: OutputFrameCallback) ---
	shim_scene_xdg_surface_set_position :: proc(scene: ^wlr_scene_xdg_surface, x: int, y: int) ---
}

timespec :: struct {
	tv_sec: i64,
	tv_nsec: i64,
}

OutputState :: struct {
	output: ^wlr_output,
	scene_output: ^wlr_scene_output,
}

Server :: struct {
	display: ^wl_display,
	backend: ^wlr_backend,
	renderer: ^wlr_renderer,
	allocator: ^wlr_allocator,
	output_layout: ^wlr_output_layout,
	scene: ^wlr_scene,
	scene_output_layout: ^wlr_scene_output_layout,
	xdg_shell: ^wlr_xdg_shell,
	seat: ^wlr_seat,
	outputs: []OutputState,
}

server_create_display :: proc() -> ^wl_display {
	return wl_display_create()
}

server_create_backend :: proc(display: ^wl_display) -> ^wlr_backend {
	return wlr_backend_autocreate(display)
}

server_create_renderer :: proc(backend: ^wlr_backend) -> ^wlr_renderer {
	return wlr_renderer_autocreate(backend)
}

server_create_allocator :: proc(backend: ^wlr_backend, renderer: ^wlr_renderer) -> ^wlr_allocator {
	return wlr_allocator_autocreate(backend, renderer)
}

CoreGlobals :: struct {
	compositor: ^wlr_compositor,
	subcompositor: ^wlr_subcompositor,
	data_device_manager: ^wlr_data_device_manager,
}

server_create_core_globals :: proc(display: ^wl_display, renderer: ^wlr_renderer) -> CoreGlobals {
	return CoreGlobals{
		compositor = wlr_compositor_create(display, renderer),
		subcompositor = wlr_subcompositor_create(display),
		data_device_manager = wlr_data_device_manager_create(display),
	}
}

server_create_output_layout :: proc() -> ^wlr_output_layout {
	return wlr_output_layout_create()
}

server_create_scene :: proc() -> ^wlr_scene {
	return wlr_scene_create()
}

server_attach_scene_to_layout :: proc(scene: ^wlr_scene, layout: ^wlr_output_layout) -> ^wlr_scene_output_layout {
	return wlr_scene_attach_output_layout(scene, layout)
}

server_create_xdg_shell :: proc(display: ^wl_display) -> ^wlr_xdg_shell {
	return wlr_xdg_shell_create(display)
}

server_create_seat :: proc(display: ^wl_display, name: cstring) -> ^wlr_seat {
	return wlr_seat_create(display, name)
}

server_start_backend :: proc(backend: ^wlr_backend) -> bool {
	return wlr_backend_start(backend)
}

server_run :: proc(display: ^wl_display) {
	wl_display_run(display)
}

output_init :: proc(server: ^Server, output: ^wlr_output) {
	mode := wlr_output_preferred_mode(output)
	if mode != nil {
		wlr_output_set_mode(output, mode)
	}
	wlr_output_enable(output, true)
	_ = wlr_output_commit(output)

	layout_output := wlr_output_layout_add_auto(server.output_layout, output)
	scene_output := wlr_scene_output_create(server.scene, output)
	if server.scene_output_layout != nil && layout_output != nil && scene_output != nil {
		wlr_scene_output_layout_add_output(server.scene_output_layout, layout_output, scene_output)
	}
	append(&server.outputs, OutputState{
		output = output,
		scene_output = scene_output,
	})

	shim_register_output_frame_listener(output, server, on_output_frame)
}

output_handle_frame :: proc(server: ^Server, output: ^wlr_output) {
	buffer_age: int
	if !wlr_output_attach_render(output, &buffer_age) {
		return
	}
	width: int
	height: int
	wlr_output_effective_resolution(output, &width, &height)

	wlr_renderer_begin(server.renderer, width, height)
	clear_color := [4]f32{0.1, 0.1, 0.1, 1.0}
	wlr_renderer_clear(server.renderer, &clear_color)
	wlr_scene_render_output(server.scene, output, nil)
	wlr_renderer_end(server.renderer)
	_ = wlr_output_commit(output)
}

view_init_from_xdg_surface :: proc(server: ^Server, xdg_surface: ^wlr_xdg_surface) {
	if wlr_xdg_surface_get_toplevel(xdg_surface) == nil {
		return
	}
	root := wlr_scene_get_root(server.scene)
	if root == nil {
		return
	}
	scene_xdg := wlr_scene_xdg_surface_create(root, xdg_surface)
	if scene_xdg == nil {
		return
	}
	shim_scene_xdg_surface_set_position(scene_xdg, 0, 0)
}

on_new_output :: proc "c" (userdata: rawptr, output: ^wlr_output) {
	server := cast(^Server)userdata
	output_init(server, output)
}

on_new_xdg_surface :: proc "c" (userdata: rawptr, surface: ^wlr_xdg_surface) {
	server := cast(^Server)userdata
	view_init_from_xdg_surface(server, surface)
}

on_output_frame :: proc "c" (userdata: rawptr, output: ^wlr_output) {
	server := cast(^Server)userdata
	output_handle_frame(server, output)
}
