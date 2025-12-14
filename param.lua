local param = {}

local state = {
    has_notification = false,
    current_menu = nil,
    menu_open = false,
    input_blocked = false,
    input_delay_frames = 0
}

function param.get_has_notification()
    return state.has_notification
end

function param.set_has_notification(has_notification)
    state.has_notification = has_notification
end

function param.get_current_menu()
    return state.current_menu
end

function param.set_current_menu(current_menu)
    state.current_menu = current_menu
end

function param.get_menu_open()
    return state.menu_open
end

function param.set_menu_open(menu_open)
    state.menu_open = menu_open
end

function param.get_input_blocked()
    return state.input_blocked
end

function param.set_input_blocked(input_blocked)
    state.input_blocked = input_blocked
end

function param.get_input_delay_frames()
    return state.input_delay_frames
end

function param.set_input_delay_frames(frames)
    state.input_delay_frames = frames
end

return param
