
-- local visited_table_list
-- function PrintTable(target_table)
--     if not target_table then
--         print("[PrintTable]: target table is nil")
--         return
--     elseif type(target_table) ~= "table" then
--         print("[PrintTable]: target value is not a table")
--         return
--     end

--     local record = {}
--     visited_table_list = {}
--     TravelTableRecursive(target_table, 0, record)
--     print(StringHelper.ConcatTable(target_table))
-- end

-- function TravelTableRecursive(target_table, cur_layer, record)
--     visited_table_list[target_table] = true
--     table.insert(record, StringHelper.GetRepeatStr("\t", cur_layer) .. "{\n")
--     for key, value in pairs(target_table) do
--         if type(value) == "string" then
--             table.insert(record, StringHelper.GetRepeatStr("\t", cur_layer) .. string.format("%s = \"%s\"\n", key, tostring(value)))
--         else
--             table.insert(record, StringHelper.GetRepeatStr("\t", cur_layer) .. string.format("%s = %s\n", key, tostring(value)))
--         end
--         if type(value) == "table" and not visited_table_list[value] then
--             TravelTableRecursive(value, cur_layer + 1, record)
--         end
--     end
--     table.insert(record, StringHelper.GetRepeatStr("\t", cur_layer) .. "}\n")
-- end

local visited_table_list = {}
local function WriteTableRecursive(table, file, cur_layer)
    if table then
        visited_table_list[table] = true
        file:write(StringHelper.GetRepeatStr("\t", cur_layer) .. "{\n")
        for key, value in pairs(table) do
            if type(value) == "string" then
                file:write(string.format("%s%s = \"%s\",\n", StringHelper.GetRepeatStr("\t", cur_layer+1), key, value))
            else
                file:write(string.format("%s%s = %s,\n", StringHelper.GetRepeatStr("\t", cur_layer+1), key, value))
            end
            if type(value) == "table" and not visited_table_list[value] then
                WriteTableRecursive(value, file, cur_layer+1)
            end
        end
        file:write(StringHelper.GetRepeatStr("\t", cur_layer) .. "}\n")
    end
end

function WriteTable(table, file_name)
    if not table then
        Debug.Log("[utils.WriteTable]: param table is nil")
        return
    elseif type(table) ~= "table" then
        Debug.Log("[utils.WriteTable]: param table is not a table")
        return
    end
    local file = io.open(file_name, 'a+')
    visited_table_list = {}
    WriteTableRecursive(table, file, 0)
    visited_table_list = {}
    file:close()
end