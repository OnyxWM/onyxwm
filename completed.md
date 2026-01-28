Implemented step 1: added Wayland FFI bindings and `server_create_display` to create and return a `wl_display`.
Implemented step 2: added wlroots FFI binding for `wlr_backend_autocreate` and `server_create_backend` to create a backend from the display.
Implemented step 3: added wlroots FFI binding for `wlr_renderer_autocreate` and `server_create_renderer` to create a renderer from the backend.
Implemented step 4: added wlroots FFI binding for `wlr_allocator_autocreate` and `server_create_allocator` to create a buffer allocator.
Implemented step 5: added core globals creation (`wlr_compositor`, `wlr_subcompositor`, `wlr_data_device_manager`) via `server_create_core_globals`.
Implemented step 6: added `wlr_output_layout_create` binding and `server_create_output_layout`.
Implemented step 7: added `wlr_scene_create` binding and `server_create_scene`.
Implemented step 8: added `wlr_scene_attach_output_layout` binding and `server_attach_scene_to_layout`.
Implemented step 9: added `wlr_xdg_shell_create` binding and `server_create_xdg_shell`.
Implemented step 10: added `wlr_seat_create` binding and `server_create_seat`.
Implemented step 11: added C shim `shim_register_new_output_listener` plus Odin binding and callback type.
Implemented step 12: added C shim `shim_register_new_xdg_surface_listener` plus Odin binding and callback type.
Implemented step 14: added C shim `shim_register_output_frame_listener` plus Odin binding and callback type.
Implemented step 17: added `wlr_backend_start` binding and `server_start_backend`.
Implemented step 18: added `wl_display_run` binding and `server_run`.
Implemented step 13: added `output_init` to configure outputs, add to layout/scene, and register frame listener.
Implemented step 15: added `output_handle_frame` render loop using `wlr_output_attach_render`, renderer begin/clear, and `wlr_scene_render_output`.
Implemented step 16: added `view_init_from_xdg_surface` to create scene xdg surfaces and position them at (0,0).
