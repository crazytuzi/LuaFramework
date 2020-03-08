local basepath = (...)
basepath = basepath or "../../"
local function get_scene_res_path(path_list)
  local InstInfo_Client = dofile(basepath .. "Configs/instance_client_data.lua")
  for k, v in pairs(InstInfo_Client) do
    if v.skybox then
      path_list[#path_list + 1] = v.skybox
    end
  end
end
local function get_material_data_path(path_list)
  local mat = dofile(basepath .. "Configs/material_data.lua")
  local path = {}
  for k, v in pairs(mat) do
    if v.path then
      path[v.path] = 1
    end
  end
  for k, v in pairs(path) do
    path_list[#path_list + 1] = k
  end
end
local function GetResPath()
  local path_list = {}
  get_scene_res_path(path_list)
  get_material_data_path(path_list)
  return path_list
end
return GetResPath()
