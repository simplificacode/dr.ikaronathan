local ie_console = {_version = "0.0.1"}
local function ie_debug_prinf_format_string_output(target_string, target_arguments)
    local valid_tag = {
        "d", -- decimal
        "f", -- floating point
        "s", -- string, boolean
        "b", -- binary string to decimal string
        "x", -- hexidecimal (lower case)
        "%" -- print % self
    }
    local error_msg_list = {
        function()
            return "invalid single % tag at the end of format string."
        end,
        function(i, next_string)
            return "invalid % tag at position: " .. tostring(i) .. ", invalid tag is: " .. next_string
        end,
        function(md_array_no_mod_len, target_arguments)
            return "invalid argument length for format string, format count: " ..
                tostring(md_array_no_mod_len) .. ", arguments count: " .. tostring(#target_arguments)
        end,
        function(target_arguments_target_arguemnts_cursor_)
            return "invalid argument for binary format (%b), your argument is: " ..
                target_arguments_target_arguemnts_cursor_
        end,
        function(target_arguments_target_arguemnts_cursor_)
            return "invalid argument for hexidecimal format (%h), your argument is: " ..
                target_arguments_target_arguemnts_cursor_
        end,
        function(target_arguments_target_arguemnts_cursor_)
            return "invalid argument for string/boolean format (%s), your argument is: " ..
                target_arguments_target_arguemnts_cursor_
        end,
        function(target_arguments_target_arguemnts_cursor_)
            return "invalid argument for decimal/float format (%d/f), your argument is: " ..
                target_arguments_target_arguemnts_cursor_
        end
    }
    local error_msg = ""
    local md_array = {}
    local is_print_mod_tag = false
    for i = 1, #target_string do
        local current_string = string.sub(target_string, i, i)
        if (is_print_mod_tag == true) then
            is_print_mod_tag = false
        elseif (current_string == "%") then
            if (i == #target_string) then
                error_msg = error_msg_list[1]()
                break
            else
                i = i + 1
                local next_string = string.sub(target_string, i, i)
                -- get current hit tag
                local hit_tag = ""
                for j = 1, #valid_tag do
                    if (valid_tag[j] == next_string) then
                        hit_tag = valid_tag[j]
                        break
                    end
                end
                if (hit_tag == "") then
                    error_msg = error_msg_list[2](i, next_string)
                    break
                end
                table.insert(md_array, {i, hit_tag})
                if (i == #target_string) then
                    break
                end
                if (hit_tag == "%") then
                    is_print_mod_tag = true
                end
            end
        end
    end

    if (error_msg ~= "") then
        return {error_msg, nil}
    end

    local md_array_len = 0
    for i, j in ipairs(md_array) do
        md_array_len = md_array_len + 1
    end
    local final_output = ""
    local md_array_no_mod_len = 0
    for k, v in ipairs(md_array) do
        if (v[2] ~= "%") then
            md_array_no_mod_len = md_array_no_mod_len + 1
        end
    end
    if (md_array_no_mod_len ~= #target_arguments) then
        error_msg = error_msg_list[3](md_array_no_mod_len, target_arguments)
        return {error_msg, nil}
    end

    local current_cursor = #target_string
    local target_string_len = #target_string
    local md_array_cursor = #md_array
    local target_arguemnts_cursor = #target_arguments
    for i = 1, target_string_len do
        if (current_cursor == (target_string_len - i + 1)) then
            if
                (md_array_cursor <= #md_array and md_array_cursor >= 1 and
                    current_cursor == md_array[md_array_cursor][1])
             then
                local ans = nil
                local is_mod = false
                if (md_array[md_array_cursor][2] == "b" or md_array[md_array_cursor][2] == "x") then
                    ans = tostring(tonumber(target_arguments[target_arguemnts_cursor]))
                    if (md_array[md_array_cursor][2] == "b") then
                        ans = tonumber(ans, 2)
                    end
                    if (ans == nil and md_array[md_array_cursor][2] == "b") then
                        error_msg = error_msg_list[4](target_arguments[target_arguemnts_cursor])
                        break
                    elseif (ans == nil and md_array[md_array_cursor][2] == "x") then
                        error_msg = error_msg_list[5](target_arguments[target_arguemnts_cursor])
                        break
                    end
                elseif (md_array[md_array_cursor][2] == "s") then
                    if
                        (type(target_arguments[target_arguemnts_cursor]) == "boolean" or
                            type(target_arguments[target_arguemnts_cursor]) == "string")
                     then
                        ans = tostring(target_arguments[target_arguemnts_cursor])
                    else
                        error_msg = error_msg_list[6](target_arguments[target_arguemnts_cursor])
                        break
                    end
                elseif (md_array[md_array_cursor][2] == "d" or md_array[md_array_cursor][2] == "f") then
                    if (type(target_arguments[target_arguemnts_cursor]) == "number") then
                        ans = tostring(target_arguments[target_arguemnts_cursor])
                    else
                        error_msg = error_msg_list[7](target_arguments[target_arguemnts_cursor])
                        break
                    end
                else
                    is_mod = true
                    ans = "%"
                end
                final_output = ans .. final_output
                md_array_cursor = md_array_cursor - 1
                if (is_mod == false) then
                    target_arguemnts_cursor = target_arguemnts_cursor - 1
                end
                current_cursor = current_cursor - 2
            else
                local current_string = string.sub(target_string, current_cursor, current_cursor)
                final_output = current_string .. final_output
                current_cursor = current_cursor - 1
            end
        end
    end
    if (error_msg ~= "") then
        return {error_msg, nil}
    end
    return {nil, final_output}
end
function ie_console.log(ie_log_value, ...)
    local ie_global_enable_log = true
    local ie_log_string_len_restriction = 200
    if (ie_global_enable_log == false) then
        return
    end
    local ie_logout_spec_tag = "ie_(O.O)ﾉ"
    local ie_log_level = 8
    local ie_log_string = tostring(ie_log_value)
    if (string.find(ie_log_string, "%%") ~= nil) then
        local ie_format_ret = ie_debug_prinf_format_string_output(ie_log_value, {...})
        if (ie_format_ret[2] == nil) then
            ie_log_string = ie_format_ret[1]
        else
            ie_log_string = ie_format_ret[2]
        end
    else
        local ie_arguments_len = 0
        local ie_arguments_table = {...}
        for k, v in ipairs(ie_arguments_table) do
            ie_arguments_len = ie_arguments_len + 1
        end
        if ie_arguments_len > 0 then
            ie_log_string = ie_log_string .. ", "
        end
        for k, v in ipairs(ie_arguments_table) do
            if (k ~= ie_arguments_len) then
                ie_log_string = ie_log_string .. tostring(v) .. ", "
            end
        end
        if ie_arguments_len ~= 0 then
            ie_log_string = ie_log_string .. tostring(ie_arguments_table[ie_arguments_len])
        end
    end
    ie_log_string = " -- " .. ie_log_string
    if (#ie_log_string > ie_log_string_len_restriction) then
        ie_log_string = string.sub(ie_log_string, 1, ie_log_string_len_restriction)
    end
    Amaz.LOGS(ie_logout_spec_tag, ie_log_string)
end
return ie_console