package main
import "base:runtime"

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
wlr_xdg_toplevel :: struct {}
wlr_scene_node :: struct {}

foreign import wayland "system:wayland-server"
foreign import wlroots "system:c"
foreign import shim "system:c"

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
	 wlr_output_layout_add_auto :: proc(layout: ^wlr_output_layout, output: ^wlr_output) -> ^wlr_output_layout_output ---
	 wlr_scene_output_create :: proc(scene: ^wlr_scene, output: ^wlr_output) -> ^wlr_scene_output ---
	 wlr_scene_output_layout_add_output :: proc(scene_layout: ^wlr_scene_output_layout, layout_output: ^wlr_output_layout_output, scene_output: ^wlr_scene_output) ---
	 wlr_output_effective_resolution :: proc(output: ^wlr_output, width: ^int, height: ^int) ---
}

NewOutputCallback :: proc "c" (userdata: rawptr, output: ^wlr_output)
NewXdgSurfaceCallback :: proc "c" (userdata: rawptr, surface: ^wlr_xdg_surface)
OutputFrameCallback :: proc "c" (userdata: rawptr, output: ^wlr_output)

foreign shim {
	shim_register_new_output_listener :: proc(backend: ^wlr_backend, userdata: rawptr, cb: NewOutputCallback) ---
	shim_register_new_xdg_surface_listener :: proc(xdg_shell: ^wlr_xdg_shell, userdata: rawptr, cb: NewXdgSurfaceCallback) ---
	 shim_register_output_frame_listener :: proc(output: ^wlr_output, userdata: rawptr, cb: OutputFrameCallback) ---
	 shim_scene_xdg_surface_create_node :: proc(
    parent: ^wlr_scene_tree,
    surface: ^wlr_xdg_surface,
) -> ^wlr_scene_node ---

	 shim_scene_node_set_position :: proc(node: ^wlr_scene_node, x: int, y: int) ---
	 shim_output_configure :: proc(output: ^wlr_output, mode: ^wlr_output_mode, enable: bool) -> bool ---
	 shim_scene_output_commit :: proc(scene_output: ^wlr_scene_output) -> bool ---
	 shim_scene_get_root :: proc(scene: ^wlr_scene) -> ^wlr_scene_tree ---
	 shim_xdg_surface_is_toplevel :: proc(surface: ^wlr_xdg_surface) -> bool ---
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
	outputs: [dynamic]OutputState,
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
	_ = shim_output_configure(output, mode, true)

	layout_output := wlr_output_layout_add_auto(server.output_layout, output)
	scene_output := wlr_scene_output_create(server.scene, output)
	if server.scene_output_layout != nil && layout_output != nil && scene_output != nil {
		wlr_scene_output_layout_add_output(server.scene_output_layout, layout_output, scene_output)
	}
_, _ = runtime.append_elem(&server.outputs, OutputState{
    output = output,
    scene_output = scene_output,
})
	shim_register_output_frame_listener(output, server, on_output_frame)
}

server_find_scene_output :: proc(server: ^Server, output: ^wlr_output) -> ^wlr_scene_output {
	for i in 0..<len(server.outputs) {
		if server.outputs[i].output == output {
			return server.outputs[i].scene_output
		}
	}
	return nil
}

output_handle_frame :: proc(server: ^Server, output: ^wlr_output) {
	scene_output := server_find_scene_output(server, output)
	if scene_output == nil {
		return
	}
	_ = shim_scene_output_commit(scene_output)
}

view_init_from_xdg_surface :: proc(server: ^Server, xdg_surface: ^wlr_xdg_surface) {
	if !shim_xdg_surface_is_toplevel(xdg_surface) {
		return
	}
	root := shim_scene_get_root(server.scene)
    if root == nil {
        return
    }

    node := shim_scene_xdg_surface_create_node(root, xdg_surface)
    if node == nil {
        return
    }

    shim_scene_node_set_position(node, 0, 0)
}

on_new_output :: proc "c" (userdata: rawptr, output: ^wlr_output) {
    context = runtime.default_context()
    server := cast(^Server)userdata
    output_init(server, output)
}

on_new_xdg_surface :: proc "c" (userdata: rawptr, surface: ^wlr_xdg_surface) {
    context = runtime.default_context()
    server := cast(^Server)userdata
    view_init_from_xdg_surface(server, surface)
}

on_output_frame :: proc "c" (userdata: rawptr, output: ^wlr_output) {
    context = runtime.default_context()
    server := cast(^Server)userdata
    output_handle_frame(server, output)
}

main :: proc() {
	display := server_create_display()
	backend := server_create_backend(display)
	renderer := server_create_renderer(backend)
	allocator := server_create_allocator(backend, renderer)
	_ = server_create_core_globals(display, renderer)
	output_layout := server_create_output_layout()
	scene := server_create_scene()
	scene_output_layout := server_attach_scene_to_layout(scene, output_layout)
	xdg_shell := server_create_xdg_shell(display)
	seat := server_create_seat(display, cstring("seat0"))

	server := Server{
		display = display,
		backend = backend,
		renderer = renderer,
		allocator = allocator,
		output_layout = output_layout,
		scene = scene,
		scene_output_layout = scene_output_layout,
		xdg_shell = xdg_shell,
		seat = seat,
	}

	shim_register_new_output_listener(backend, &server, on_new_output)
	shim_register_new_xdg_surface_listener(xdg_shell, &server, on_new_xdg_surface)

	if !server_start_backend(backend) {
		return
	}
	server_run(display)
}
