local protobuf = require("protobuf.protobuf")
local pb = require("pb")
local _M = {}
if _VERSION == "Lua 5.1" then
  setfenv(1, _M)
end
local _ENV = _M
do
  local role_cfg = protobuf.Descriptor()
  local role_cfg_version_FIELD = protobuf.FieldDescriptor()
  local role_cfg_data_FIELD = protobuf.FieldDescriptor()
  role_cfg_version_FIELD.name = "version"
  role_cfg_version_FIELD.full_name = "PB.role_cfg_version"
  role_cfg_version_FIELD.number = 1
  role_cfg_version_FIELD.index = 0
  role_cfg_version_FIELD.label = 1
  role_cfg_version_FIELD.has_default_value = true
  role_cfg_version_FIELD.default_value = 0
  role_cfg_version_FIELD.type = 5
  role_cfg_version_FIELD.cpp_type = 1
  role_cfg_data_FIELD.name = "data"
  role_cfg_data_FIELD.full_name = "PB.role_cfg_data"
  role_cfg_data_FIELD.number = 2
  role_cfg_data_FIELD.index = 1
  role_cfg_data_FIELD.label = 1
  role_cfg_data_FIELD.has_default_value = false
  role_cfg_data_FIELD.default_value = ""
  role_cfg_data_FIELD.type = 12
  role_cfg_data_FIELD.cpp_type = 9
  role_cfg.name = "role_cfg"
  role_cfg.full_name = "PB.role_cfg"
  role_cfg.nested_types = {}
  role_cfg.enum_types = {}
  role_cfg.fields = {role_cfg_version_FIELD, role_cfg_data_FIELD}
  role_cfg.is_extendable = false
  role_cfg.extensions = {}
  _M.role_cfg = protobuf.Message(role_cfg)
end
return _M
