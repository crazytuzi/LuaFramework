local protobuf = require("protobuf.protobuf")
local pb = require("pb")
local _M = {}
if _VERSION == "Lua 5.1" then
  setfenv(1, _M)
end
local _ENV = _M
do
  local FileDescriptorSet = protobuf.Descriptor()
  local FileDescriptorSet_file_FIELD = protobuf.FieldDescriptor()
  FileDescriptorSet_file_FIELD.name = "file"
  FileDescriptorSet_file_FIELD.full_name = "google.protobuf.FileDescriptorSet_file"
  FileDescriptorSet_file_FIELD.number = 1
  FileDescriptorSet_file_FIELD.index = 0
  FileDescriptorSet_file_FIELD.label = 3
  FileDescriptorSet_file_FIELD.has_default_value = false
  FileDescriptorSet_file_FIELD.default_value = {}
  FileDescriptorSet_file_FIELD.message_type = FileDescriptorProto.GetDescriptor()
  FileDescriptorSet_file_FIELD.type = 11
  FileDescriptorSet_file_FIELD.cpp_type = 10
  FileDescriptorSet.name = "FileDescriptorSet"
  FileDescriptorSet.full_name = "google.protobuf.FileDescriptorSet"
  FileDescriptorSet.nested_types = {}
  FileDescriptorSet.enum_types = {}
  FileDescriptorSet.fields = {FileDescriptorSet_file_FIELD}
  FileDescriptorSet.is_extendable = false
  FileDescriptorSet.extensions = {}
  _M.FileDescriptorSet = protobuf.Message(FileDescriptorSet)
end
do
  local FileDescriptorProto = protobuf.Descriptor()
  local FileDescriptorProto_name_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_package_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_dependency_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_public_dependency_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_weak_dependency_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_message_type_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_enum_type_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_service_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_extension_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_options_FIELD = protobuf.FieldDescriptor()
  local FileDescriptorProto_source_code_info_FIELD = protobuf.FieldDescriptor()
  FileDescriptorProto_name_FIELD.name = "name"
  FileDescriptorProto_name_FIELD.full_name = "google.protobuf.FileDescriptorProto_name"
  FileDescriptorProto_name_FIELD.number = 1
  FileDescriptorProto_name_FIELD.index = 0
  FileDescriptorProto_name_FIELD.label = 1
  FileDescriptorProto_name_FIELD.has_default_value = false
  FileDescriptorProto_name_FIELD.default_value = ""
  FileDescriptorProto_name_FIELD.type = 9
  FileDescriptorProto_name_FIELD.cpp_type = 9
  FileDescriptorProto_package_FIELD.name = "package"
  FileDescriptorProto_package_FIELD.full_name = "google.protobuf.FileDescriptorProto_package"
  FileDescriptorProto_package_FIELD.number = 2
  FileDescriptorProto_package_FIELD.index = 1
  FileDescriptorProto_package_FIELD.label = 1
  FileDescriptorProto_package_FIELD.has_default_value = false
  FileDescriptorProto_package_FIELD.default_value = ""
  FileDescriptorProto_package_FIELD.type = 9
  FileDescriptorProto_package_FIELD.cpp_type = 9
  FileDescriptorProto_dependency_FIELD.name = "dependency"
  FileDescriptorProto_dependency_FIELD.full_name = "google.protobuf.FileDescriptorProto_dependency"
  FileDescriptorProto_dependency_FIELD.number = 3
  FileDescriptorProto_dependency_FIELD.index = 2
  FileDescriptorProto_dependency_FIELD.label = 3
  FileDescriptorProto_dependency_FIELD.has_default_value = false
  FileDescriptorProto_dependency_FIELD.default_value = {}
  FileDescriptorProto_dependency_FIELD.type = 9
  FileDescriptorProto_dependency_FIELD.cpp_type = 9
  FileDescriptorProto_public_dependency_FIELD.name = "public_dependency"
  FileDescriptorProto_public_dependency_FIELD.full_name = "google.protobuf.FileDescriptorProto_public_dependency"
  FileDescriptorProto_public_dependency_FIELD.number = 10
  FileDescriptorProto_public_dependency_FIELD.index = 3
  FileDescriptorProto_public_dependency_FIELD.label = 3
  FileDescriptorProto_public_dependency_FIELD.has_default_value = false
  FileDescriptorProto_public_dependency_FIELD.default_value = {}
  FileDescriptorProto_public_dependency_FIELD.type = 5
  FileDescriptorProto_public_dependency_FIELD.cpp_type = 1
  FileDescriptorProto_weak_dependency_FIELD.name = "weak_dependency"
  FileDescriptorProto_weak_dependency_FIELD.full_name = "google.protobuf.FileDescriptorProto_weak_dependency"
  FileDescriptorProto_weak_dependency_FIELD.number = 11
  FileDescriptorProto_weak_dependency_FIELD.index = 4
  FileDescriptorProto_weak_dependency_FIELD.label = 3
  FileDescriptorProto_weak_dependency_FIELD.has_default_value = false
  FileDescriptorProto_weak_dependency_FIELD.default_value = {}
  FileDescriptorProto_weak_dependency_FIELD.type = 5
  FileDescriptorProto_weak_dependency_FIELD.cpp_type = 1
  FileDescriptorProto_message_type_FIELD.name = "message_type"
  FileDescriptorProto_message_type_FIELD.full_name = "google.protobuf.FileDescriptorProto_message_type"
  FileDescriptorProto_message_type_FIELD.number = 4
  FileDescriptorProto_message_type_FIELD.index = 5
  FileDescriptorProto_message_type_FIELD.label = 3
  FileDescriptorProto_message_type_FIELD.has_default_value = false
  FileDescriptorProto_message_type_FIELD.default_value = {}
  FileDescriptorProto_message_type_FIELD.message_type = DescriptorProto.GetDescriptor()
  FileDescriptorProto_message_type_FIELD.type = 11
  FileDescriptorProto_message_type_FIELD.cpp_type = 10
  FileDescriptorProto_enum_type_FIELD.name = "enum_type"
  FileDescriptorProto_enum_type_FIELD.full_name = "google.protobuf.FileDescriptorProto_enum_type"
  FileDescriptorProto_enum_type_FIELD.number = 5
  FileDescriptorProto_enum_type_FIELD.index = 6
  FileDescriptorProto_enum_type_FIELD.label = 3
  FileDescriptorProto_enum_type_FIELD.has_default_value = false
  FileDescriptorProto_enum_type_FIELD.default_value = {}
  FileDescriptorProto_enum_type_FIELD.message_type = EnumDescriptorProto.GetDescriptor()
  FileDescriptorProto_enum_type_FIELD.type = 11
  FileDescriptorProto_enum_type_FIELD.cpp_type = 10
  FileDescriptorProto_service_FIELD.name = "service"
  FileDescriptorProto_service_FIELD.full_name = "google.protobuf.FileDescriptorProto_service"
  FileDescriptorProto_service_FIELD.number = 6
  FileDescriptorProto_service_FIELD.index = 7
  FileDescriptorProto_service_FIELD.label = 3
  FileDescriptorProto_service_FIELD.has_default_value = false
  FileDescriptorProto_service_FIELD.default_value = {}
  FileDescriptorProto_service_FIELD.message_type = ServiceDescriptorProto.GetDescriptor()
  FileDescriptorProto_service_FIELD.type = 11
  FileDescriptorProto_service_FIELD.cpp_type = 10
  FileDescriptorProto_extension_FIELD.name = "extension"
  FileDescriptorProto_extension_FIELD.full_name = "google.protobuf.FileDescriptorProto_extension"
  FileDescriptorProto_extension_FIELD.number = 7
  FileDescriptorProto_extension_FIELD.index = 8
  FileDescriptorProto_extension_FIELD.label = 3
  FileDescriptorProto_extension_FIELD.has_default_value = false
  FileDescriptorProto_extension_FIELD.default_value = {}
  FileDescriptorProto_extension_FIELD.message_type = FieldDescriptorProto.GetDescriptor()
  FileDescriptorProto_extension_FIELD.type = 11
  FileDescriptorProto_extension_FIELD.cpp_type = 10
  FileDescriptorProto_options_FIELD.name = "options"
  FileDescriptorProto_options_FIELD.full_name = "google.protobuf.FileDescriptorProto_options"
  FileDescriptorProto_options_FIELD.number = 8
  FileDescriptorProto_options_FIELD.index = 9
  FileDescriptorProto_options_FIELD.label = 1
  FileDescriptorProto_options_FIELD.has_default_value = false
  FileDescriptorProto_options_FIELD.default_value = nil
  FileDescriptorProto_options_FIELD.message_type = FileOptions.GetDescriptor()
  FileDescriptorProto_options_FIELD.type = 11
  FileDescriptorProto_options_FIELD.cpp_type = 10
  FileDescriptorProto_source_code_info_FIELD.name = "source_code_info"
  FileDescriptorProto_source_code_info_FIELD.full_name = "google.protobuf.FileDescriptorProto_source_code_info"
  FileDescriptorProto_source_code_info_FIELD.number = 9
  FileDescriptorProto_source_code_info_FIELD.index = 10
  FileDescriptorProto_source_code_info_FIELD.label = 1
  FileDescriptorProto_source_code_info_FIELD.has_default_value = false
  FileDescriptorProto_source_code_info_FIELD.default_value = nil
  FileDescriptorProto_source_code_info_FIELD.message_type = SourceCodeInfo.GetDescriptor()
  FileDescriptorProto_source_code_info_FIELD.type = 11
  FileDescriptorProto_source_code_info_FIELD.cpp_type = 10
  FileDescriptorProto.name = "FileDescriptorProto"
  FileDescriptorProto.full_name = "google.protobuf.FileDescriptorProto"
  FileDescriptorProto.nested_types = {}
  FileDescriptorProto.enum_types = {}
  FileDescriptorProto.fields = {
    FileDescriptorProto_name_FIELD,
    FileDescriptorProto_package_FIELD,
    FileDescriptorProto_dependency_FIELD,
    FileDescriptorProto_public_dependency_FIELD,
    FileDescriptorProto_weak_dependency_FIELD,
    FileDescriptorProto_message_type_FIELD,
    FileDescriptorProto_enum_type_FIELD,
    FileDescriptorProto_service_FIELD,
    FileDescriptorProto_extension_FIELD,
    FileDescriptorProto_options_FIELD,
    FileDescriptorProto_source_code_info_FIELD
  }
  FileDescriptorProto.is_extendable = false
  FileDescriptorProto.extensions = {}
  _M.FileDescriptorProto = protobuf.Message(FileDescriptorProto)
end
do
  local DescriptorProto = protobuf.Descriptor()
  DescriptorProto.ExtensionRange = protobuf.Descriptor()
  DescriptorProto.ExtensionRange_start_FIELD = protobuf.FieldDescriptor()
  DescriptorProto.ExtensionRange_end_FIELD = protobuf.FieldDescriptor()
  do
    local DescriptorProto_name_FIELD = protobuf.FieldDescriptor()
    local DescriptorProto_field_FIELD = protobuf.FieldDescriptor()
    local DescriptorProto_extension_FIELD = protobuf.FieldDescriptor()
    local DescriptorProto_nested_type_FIELD = protobuf.FieldDescriptor()
    local DescriptorProto_enum_type_FIELD = protobuf.FieldDescriptor()
    local DescriptorProto_extension_range_FIELD = protobuf.FieldDescriptor()
    local DescriptorProto_options_FIELD = protobuf.FieldDescriptor()
    DescriptorProto.ExtensionRange_start_FIELD.name = "start"
    DescriptorProto.ExtensionRange_start_FIELD.full_name = "google.protobuf.DescriptorProto.ExtensionRange_start"
    DescriptorProto.ExtensionRange_start_FIELD.number = 1
    DescriptorProto.ExtensionRange_start_FIELD.index = 0
    DescriptorProto.ExtensionRange_start_FIELD.label = 1
    DescriptorProto.ExtensionRange_start_FIELD.has_default_value = false
    DescriptorProto.ExtensionRange_start_FIELD.default_value = 0
    DescriptorProto.ExtensionRange_start_FIELD.type = 5
    DescriptorProto.ExtensionRange_start_FIELD.cpp_type = 1
    DescriptorProto.ExtensionRange_end_FIELD.name = "end"
    DescriptorProto.ExtensionRange_end_FIELD.full_name = "google.protobuf.DescriptorProto.ExtensionRange_end"
    DescriptorProto.ExtensionRange_end_FIELD.number = 2
    DescriptorProto.ExtensionRange_end_FIELD.index = 1
    DescriptorProto.ExtensionRange_end_FIELD.label = 1
    DescriptorProto.ExtensionRange_end_FIELD.has_default_value = false
    DescriptorProto.ExtensionRange_end_FIELD.default_value = 0
    DescriptorProto.ExtensionRange_end_FIELD.type = 5
    DescriptorProto.ExtensionRange_end_FIELD.cpp_type = 1
    DescriptorProto.ExtensionRange.name = "ExtensionRange"
    DescriptorProto.ExtensionRange.full_name = "google.protobuf.DescriptorProto.ExtensionRange"
    DescriptorProto.ExtensionRange.nested_types = {}
    DescriptorProto.ExtensionRange.enum_types = {}
    DescriptorProto.ExtensionRange.fields = {
      DescriptorProto.ExtensionRange_start_FIELD,
      DescriptorProto.ExtensionRange_end_FIELD
    }
    DescriptorProto.ExtensionRange.is_extendable = false
    DescriptorProto.ExtensionRange.extensions = {}
    DescriptorProto.ExtensionRange.containing_type = DescriptorProto
    DescriptorProto_name_FIELD.name = "name"
    DescriptorProto_name_FIELD.full_name = "google.protobuf.DescriptorProto_name"
    DescriptorProto_name_FIELD.number = 1
    DescriptorProto_name_FIELD.index = 0
    DescriptorProto_name_FIELD.label = 1
    DescriptorProto_name_FIELD.has_default_value = false
    DescriptorProto_name_FIELD.default_value = ""
    DescriptorProto_name_FIELD.type = 9
    DescriptorProto_name_FIELD.cpp_type = 9
    DescriptorProto_field_FIELD.name = "field"
    DescriptorProto_field_FIELD.full_name = "google.protobuf.DescriptorProto_field"
    DescriptorProto_field_FIELD.number = 2
    DescriptorProto_field_FIELD.index = 1
    DescriptorProto_field_FIELD.label = 3
    DescriptorProto_field_FIELD.has_default_value = false
    DescriptorProto_field_FIELD.default_value = {}
    DescriptorProto_field_FIELD.message_type = FieldDescriptorProto.GetDescriptor()
    DescriptorProto_field_FIELD.type = 11
    DescriptorProto_field_FIELD.cpp_type = 10
    DescriptorProto_extension_FIELD.name = "extension"
    DescriptorProto_extension_FIELD.full_name = "google.protobuf.DescriptorProto_extension"
    DescriptorProto_extension_FIELD.number = 6
    DescriptorProto_extension_FIELD.index = 2
    DescriptorProto_extension_FIELD.label = 3
    DescriptorProto_extension_FIELD.has_default_value = false
    DescriptorProto_extension_FIELD.default_value = {}
    DescriptorProto_extension_FIELD.message_type = FieldDescriptorProto.GetDescriptor()
    DescriptorProto_extension_FIELD.type = 11
    DescriptorProto_extension_FIELD.cpp_type = 10
    DescriptorProto_nested_type_FIELD.name = "nested_type"
    DescriptorProto_nested_type_FIELD.full_name = "google.protobuf.DescriptorProto_nested_type"
    DescriptorProto_nested_type_FIELD.number = 3
    DescriptorProto_nested_type_FIELD.index = 3
    DescriptorProto_nested_type_FIELD.label = 3
    DescriptorProto_nested_type_FIELD.has_default_value = false
    DescriptorProto_nested_type_FIELD.default_value = {}
    DescriptorProto_nested_type_FIELD.message_type = DescriptorProto.GetDescriptor()
    DescriptorProto_nested_type_FIELD.type = 11
    DescriptorProto_nested_type_FIELD.cpp_type = 10
    DescriptorProto_enum_type_FIELD.name = "enum_type"
    DescriptorProto_enum_type_FIELD.full_name = "google.protobuf.DescriptorProto_enum_type"
    DescriptorProto_enum_type_FIELD.number = 4
    DescriptorProto_enum_type_FIELD.index = 4
    DescriptorProto_enum_type_FIELD.label = 3
    DescriptorProto_enum_type_FIELD.has_default_value = false
    DescriptorProto_enum_type_FIELD.default_value = {}
    DescriptorProto_enum_type_FIELD.message_type = EnumDescriptorProto.GetDescriptor()
    DescriptorProto_enum_type_FIELD.type = 11
    DescriptorProto_enum_type_FIELD.cpp_type = 10
    DescriptorProto_extension_range_FIELD.name = "extension_range"
    DescriptorProto_extension_range_FIELD.full_name = "google.protobuf.DescriptorProto_extension_range"
    DescriptorProto_extension_range_FIELD.number = 5
    DescriptorProto_extension_range_FIELD.index = 5
    DescriptorProto_extension_range_FIELD.label = 3
    DescriptorProto_extension_range_FIELD.has_default_value = false
    DescriptorProto_extension_range_FIELD.default_value = {}
    DescriptorProto_extension_range_FIELD.message_type = DescriptorProto.ExtensionRange.GetDescriptor()
    DescriptorProto_extension_range_FIELD.type = 11
    DescriptorProto_extension_range_FIELD.cpp_type = 10
    DescriptorProto_options_FIELD.name = "options"
    DescriptorProto_options_FIELD.full_name = "google.protobuf.DescriptorProto_options"
    DescriptorProto_options_FIELD.number = 7
    DescriptorProto_options_FIELD.index = 6
    DescriptorProto_options_FIELD.label = 1
    DescriptorProto_options_FIELD.has_default_value = false
    DescriptorProto_options_FIELD.default_value = nil
    DescriptorProto_options_FIELD.message_type = MessageOptions.GetDescriptor()
    DescriptorProto_options_FIELD.type = 11
    DescriptorProto_options_FIELD.cpp_type = 10
    DescriptorProto.name = "DescriptorProto"
    DescriptorProto.full_name = "google.protobuf.DescriptorProto"
    DescriptorProto.nested_types = {
      DescriptorProto.ExtensionRange
    }
    DescriptorProto.enum_types = {}
    DescriptorProto.fields = {
      DescriptorProto_name_FIELD,
      DescriptorProto_field_FIELD,
      DescriptorProto_extension_FIELD,
      DescriptorProto_nested_type_FIELD,
      DescriptorProto_enum_type_FIELD,
      DescriptorProto_extension_range_FIELD,
      DescriptorProto_options_FIELD
    }
    DescriptorProto.is_extendable = false
    DescriptorProto.extensions = {}
    _M.DescriptorProto = protobuf.Message(DescriptorProto)
  end
  _M.DescriptorProto.ExtensionRange = protobuf.Message(DescriptorProto.ExtensionRange)
end
do
  local FieldDescriptorProto = protobuf.Descriptor()
  FieldDescriptorProto.Type = protobuf.EnumDescriptor()
  FieldDescriptorProto.Type_TYPE_DOUBLE_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_FLOAT_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_INT64_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_UINT64_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_INT32_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_FIXED64_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_FIXED32_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_BOOL_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_STRING_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_GROUP_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_MESSAGE_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_BYTES_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_UINT32_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_ENUM_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_SFIXED32_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_SFIXED64_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_SINT32_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Type_TYPE_SINT64_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Label = protobuf.EnumDescriptor()
  FieldDescriptorProto.Label_LABEL_OPTIONAL_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Label_LABEL_REQUIRED_ENUM = protobuf.EnumValueDescriptor()
  FieldDescriptorProto.Label_LABEL_REPEATED_ENUM = protobuf.EnumValueDescriptor()
  do
    local FieldDescriptorProto_name_FIELD = protobuf.FieldDescriptor()
    local FieldDescriptorProto_number_FIELD = protobuf.FieldDescriptor()
    local FieldDescriptorProto_label_FIELD = protobuf.FieldDescriptor()
    local FieldDescriptorProto_type_FIELD = protobuf.FieldDescriptor()
    local FieldDescriptorProto_type_name_FIELD = protobuf.FieldDescriptor()
    local FieldDescriptorProto_extendee_FIELD = protobuf.FieldDescriptor()
    local FieldDescriptorProto_default_value_FIELD = protobuf.FieldDescriptor()
    local FieldDescriptorProto_options_FIELD = protobuf.FieldDescriptor()
    FieldDescriptorProto.Type_TYPE_DOUBLE_ENUM.name = "TYPE_DOUBLE"
    FieldDescriptorProto.Type_TYPE_DOUBLE_ENUM.index = 0
    FieldDescriptorProto.Type_TYPE_DOUBLE_ENUM.number = 1
    FieldDescriptorProto.Type_TYPE_FLOAT_ENUM.name = "TYPE_FLOAT"
    FieldDescriptorProto.Type_TYPE_FLOAT_ENUM.index = 1
    FieldDescriptorProto.Type_TYPE_FLOAT_ENUM.number = 2
    FieldDescriptorProto.Type_TYPE_INT64_ENUM.name = "TYPE_INT64"
    FieldDescriptorProto.Type_TYPE_INT64_ENUM.index = 2
    FieldDescriptorProto.Type_TYPE_INT64_ENUM.number = 3
    FieldDescriptorProto.Type_TYPE_UINT64_ENUM.name = "TYPE_UINT64"
    FieldDescriptorProto.Type_TYPE_UINT64_ENUM.index = 3
    FieldDescriptorProto.Type_TYPE_UINT64_ENUM.number = 4
    FieldDescriptorProto.Type_TYPE_INT32_ENUM.name = "TYPE_INT32"
    FieldDescriptorProto.Type_TYPE_INT32_ENUM.index = 4
    FieldDescriptorProto.Type_TYPE_INT32_ENUM.number = 5
    FieldDescriptorProto.Type_TYPE_FIXED64_ENUM.name = "TYPE_FIXED64"
    FieldDescriptorProto.Type_TYPE_FIXED64_ENUM.index = 5
    FieldDescriptorProto.Type_TYPE_FIXED64_ENUM.number = 6
    FieldDescriptorProto.Type_TYPE_FIXED32_ENUM.name = "TYPE_FIXED32"
    FieldDescriptorProto.Type_TYPE_FIXED32_ENUM.index = 6
    FieldDescriptorProto.Type_TYPE_FIXED32_ENUM.number = 7
    FieldDescriptorProto.Type_TYPE_BOOL_ENUM.name = "TYPE_BOOL"
    FieldDescriptorProto.Type_TYPE_BOOL_ENUM.index = 7
    FieldDescriptorProto.Type_TYPE_BOOL_ENUM.number = 8
    FieldDescriptorProto.Type_TYPE_STRING_ENUM.name = "TYPE_STRING"
    FieldDescriptorProto.Type_TYPE_STRING_ENUM.index = 8
    FieldDescriptorProto.Type_TYPE_STRING_ENUM.number = 9
    FieldDescriptorProto.Type_TYPE_GROUP_ENUM.name = "TYPE_GROUP"
    FieldDescriptorProto.Type_TYPE_GROUP_ENUM.index = 9
    FieldDescriptorProto.Type_TYPE_GROUP_ENUM.number = 10
    FieldDescriptorProto.Type_TYPE_MESSAGE_ENUM.name = "TYPE_MESSAGE"
    FieldDescriptorProto.Type_TYPE_MESSAGE_ENUM.index = 10
    FieldDescriptorProto.Type_TYPE_MESSAGE_ENUM.number = 11
    FieldDescriptorProto.Type_TYPE_BYTES_ENUM.name = "TYPE_BYTES"
    FieldDescriptorProto.Type_TYPE_BYTES_ENUM.index = 11
    FieldDescriptorProto.Type_TYPE_BYTES_ENUM.number = 12
    FieldDescriptorProto.Type_TYPE_UINT32_ENUM.name = "TYPE_UINT32"
    FieldDescriptorProto.Type_TYPE_UINT32_ENUM.index = 12
    FieldDescriptorProto.Type_TYPE_UINT32_ENUM.number = 13
    FieldDescriptorProto.Type_TYPE_ENUM_ENUM.name = "TYPE_ENUM"
    FieldDescriptorProto.Type_TYPE_ENUM_ENUM.index = 13
    FieldDescriptorProto.Type_TYPE_ENUM_ENUM.number = 14
    FieldDescriptorProto.Type_TYPE_SFIXED32_ENUM.name = "TYPE_SFIXED32"
    FieldDescriptorProto.Type_TYPE_SFIXED32_ENUM.index = 14
    FieldDescriptorProto.Type_TYPE_SFIXED32_ENUM.number = 15
    FieldDescriptorProto.Type_TYPE_SFIXED64_ENUM.name = "TYPE_SFIXED64"
    FieldDescriptorProto.Type_TYPE_SFIXED64_ENUM.index = 15
    FieldDescriptorProto.Type_TYPE_SFIXED64_ENUM.number = 16
    FieldDescriptorProto.Type_TYPE_SINT32_ENUM.name = "TYPE_SINT32"
    FieldDescriptorProto.Type_TYPE_SINT32_ENUM.index = 16
    FieldDescriptorProto.Type_TYPE_SINT32_ENUM.number = 17
    FieldDescriptorProto.Type_TYPE_SINT64_ENUM.name = "TYPE_SINT64"
    FieldDescriptorProto.Type_TYPE_SINT64_ENUM.index = 17
    FieldDescriptorProto.Type_TYPE_SINT64_ENUM.number = 18
    FieldDescriptorProto.Type.name = "Type"
    FieldDescriptorProto.Type.full_name = "google.protobuf.FieldDescriptorProto.Type"
    FieldDescriptorProto.Type.values = {
      FieldDescriptorProto.Type_TYPE_DOUBLE_ENUM,
      FieldDescriptorProto.Type_TYPE_FLOAT_ENUM,
      FieldDescriptorProto.Type_TYPE_INT64_ENUM,
      FieldDescriptorProto.Type_TYPE_UINT64_ENUM,
      FieldDescriptorProto.Type_TYPE_INT32_ENUM,
      FieldDescriptorProto.Type_TYPE_FIXED64_ENUM,
      FieldDescriptorProto.Type_TYPE_FIXED32_ENUM,
      FieldDescriptorProto.Type_TYPE_BOOL_ENUM,
      FieldDescriptorProto.Type_TYPE_STRING_ENUM,
      FieldDescriptorProto.Type_TYPE_GROUP_ENUM,
      FieldDescriptorProto.Type_TYPE_MESSAGE_ENUM,
      FieldDescriptorProto.Type_TYPE_BYTES_ENUM,
      FieldDescriptorProto.Type_TYPE_UINT32_ENUM,
      FieldDescriptorProto.Type_TYPE_ENUM_ENUM,
      FieldDescriptorProto.Type_TYPE_SFIXED32_ENUM,
      FieldDescriptorProto.Type_TYPE_SFIXED64_ENUM,
      FieldDescriptorProto.Type_TYPE_SINT32_ENUM,
      FieldDescriptorProto.Type_TYPE_SINT64_ENUM
    }
    FieldDescriptorProto.Label_LABEL_OPTIONAL_ENUM.name = "LABEL_OPTIONAL"
    FieldDescriptorProto.Label_LABEL_OPTIONAL_ENUM.index = 0
    FieldDescriptorProto.Label_LABEL_OPTIONAL_ENUM.number = 1
    FieldDescriptorProto.Label_LABEL_REQUIRED_ENUM.name = "LABEL_REQUIRED"
    FieldDescriptorProto.Label_LABEL_REQUIRED_ENUM.index = 1
    FieldDescriptorProto.Label_LABEL_REQUIRED_ENUM.number = 2
    FieldDescriptorProto.Label_LABEL_REPEATED_ENUM.name = "LABEL_REPEATED"
    FieldDescriptorProto.Label_LABEL_REPEATED_ENUM.index = 2
    FieldDescriptorProto.Label_LABEL_REPEATED_ENUM.number = 3
    FieldDescriptorProto.Label.name = "Label"
    FieldDescriptorProto.Label.full_name = "google.protobuf.FieldDescriptorProto.Label"
    FieldDescriptorProto.Label.values = {
      FieldDescriptorProto.Label_LABEL_OPTIONAL_ENUM,
      FieldDescriptorProto.Label_LABEL_REQUIRED_ENUM,
      FieldDescriptorProto.Label_LABEL_REPEATED_ENUM
    }
    FieldDescriptorProto_name_FIELD.name = "name"
    FieldDescriptorProto_name_FIELD.full_name = "google.protobuf.FieldDescriptorProto_name"
    FieldDescriptorProto_name_FIELD.number = 1
    FieldDescriptorProto_name_FIELD.index = 0
    FieldDescriptorProto_name_FIELD.label = 1
    FieldDescriptorProto_name_FIELD.has_default_value = false
    FieldDescriptorProto_name_FIELD.default_value = ""
    FieldDescriptorProto_name_FIELD.type = 9
    FieldDescriptorProto_name_FIELD.cpp_type = 9
    FieldDescriptorProto_number_FIELD.name = "number"
    FieldDescriptorProto_number_FIELD.full_name = "google.protobuf.FieldDescriptorProto_number"
    FieldDescriptorProto_number_FIELD.number = 3
    FieldDescriptorProto_number_FIELD.index = 1
    FieldDescriptorProto_number_FIELD.label = 1
    FieldDescriptorProto_number_FIELD.has_default_value = false
    FieldDescriptorProto_number_FIELD.default_value = 0
    FieldDescriptorProto_number_FIELD.type = 5
    FieldDescriptorProto_number_FIELD.cpp_type = 1
    FieldDescriptorProto_label_FIELD.name = "label"
    FieldDescriptorProto_label_FIELD.full_name = "google.protobuf.FieldDescriptorProto_label"
    FieldDescriptorProto_label_FIELD.number = 4
    FieldDescriptorProto_label_FIELD.index = 2
    FieldDescriptorProto_label_FIELD.label = 1
    FieldDescriptorProto_label_FIELD.has_default_value = false
    FieldDescriptorProto_label_FIELD.default_value = nil
    FieldDescriptorProto_label_FIELD.enum_type = FieldDescriptorProto.Label
    FieldDescriptorProto_label_FIELD.type = 14
    FieldDescriptorProto_label_FIELD.cpp_type = 8
    FieldDescriptorProto_type_FIELD.name = "type"
    FieldDescriptorProto_type_FIELD.full_name = "google.protobuf.FieldDescriptorProto_type"
    FieldDescriptorProto_type_FIELD.number = 5
    FieldDescriptorProto_type_FIELD.index = 3
    FieldDescriptorProto_type_FIELD.label = 1
    FieldDescriptorProto_type_FIELD.has_default_value = false
    FieldDescriptorProto_type_FIELD.default_value = nil
    FieldDescriptorProto_type_FIELD.enum_type = FieldDescriptorProto.Type
    FieldDescriptorProto_type_FIELD.type = 14
    FieldDescriptorProto_type_FIELD.cpp_type = 8
    FieldDescriptorProto_type_name_FIELD.name = "type_name"
    FieldDescriptorProto_type_name_FIELD.full_name = "google.protobuf.FieldDescriptorProto_type_name"
    FieldDescriptorProto_type_name_FIELD.number = 6
    FieldDescriptorProto_type_name_FIELD.index = 4
    FieldDescriptorProto_type_name_FIELD.label = 1
    FieldDescriptorProto_type_name_FIELD.has_default_value = false
    FieldDescriptorProto_type_name_FIELD.default_value = ""
    FieldDescriptorProto_type_name_FIELD.type = 9
    FieldDescriptorProto_type_name_FIELD.cpp_type = 9
    FieldDescriptorProto_extendee_FIELD.name = "extendee"
    FieldDescriptorProto_extendee_FIELD.full_name = "google.protobuf.FieldDescriptorProto_extendee"
    FieldDescriptorProto_extendee_FIELD.number = 2
    FieldDescriptorProto_extendee_FIELD.index = 5
    FieldDescriptorProto_extendee_FIELD.label = 1
    FieldDescriptorProto_extendee_FIELD.has_default_value = false
    FieldDescriptorProto_extendee_FIELD.default_value = ""
    FieldDescriptorProto_extendee_FIELD.type = 9
    FieldDescriptorProto_extendee_FIELD.cpp_type = 9
    FieldDescriptorProto_default_value_FIELD.name = "default_value"
    FieldDescriptorProto_default_value_FIELD.full_name = "google.protobuf.FieldDescriptorProto_default_value"
    FieldDescriptorProto_default_value_FIELD.number = 7
    FieldDescriptorProto_default_value_FIELD.index = 6
    FieldDescriptorProto_default_value_FIELD.label = 1
    FieldDescriptorProto_default_value_FIELD.has_default_value = false
    FieldDescriptorProto_default_value_FIELD.default_value = ""
    FieldDescriptorProto_default_value_FIELD.type = 9
    FieldDescriptorProto_default_value_FIELD.cpp_type = 9
    FieldDescriptorProto_options_FIELD.name = "options"
    FieldDescriptorProto_options_FIELD.full_name = "google.protobuf.FieldDescriptorProto_options"
    FieldDescriptorProto_options_FIELD.number = 8
    FieldDescriptorProto_options_FIELD.index = 7
    FieldDescriptorProto_options_FIELD.label = 1
    FieldDescriptorProto_options_FIELD.has_default_value = false
    FieldDescriptorProto_options_FIELD.default_value = nil
    FieldDescriptorProto_options_FIELD.message_type = FieldOptions.GetDescriptor()
    FieldDescriptorProto_options_FIELD.type = 11
    FieldDescriptorProto_options_FIELD.cpp_type = 10
    FieldDescriptorProto.name = "FieldDescriptorProto"
    FieldDescriptorProto.full_name = "google.protobuf.FieldDescriptorProto"
    FieldDescriptorProto.nested_types = {}
    FieldDescriptorProto.enum_types = {
      FieldDescriptorProto.Type,
      FieldDescriptorProto.Label
    }
    FieldDescriptorProto.fields = {
      FieldDescriptorProto_name_FIELD,
      FieldDescriptorProto_number_FIELD,
      FieldDescriptorProto_label_FIELD,
      FieldDescriptorProto_type_FIELD,
      FieldDescriptorProto_type_name_FIELD,
      FieldDescriptorProto_extendee_FIELD,
      FieldDescriptorProto_default_value_FIELD,
      FieldDescriptorProto_options_FIELD
    }
    FieldDescriptorProto.is_extendable = false
    FieldDescriptorProto.extensions = {}
    TYPE_DOUBLE = 1
    TYPE_FLOAT = 2
    TYPE_INT64 = 3
    TYPE_UINT64 = 4
    TYPE_INT32 = 5
    TYPE_FIXED64 = 6
    TYPE_FIXED32 = 7
    TYPE_BOOL = 8
    TYPE_STRING = 9
    TYPE_GROUP = 10
    TYPE_MESSAGE = 11
    TYPE_BYTES = 12
    TYPE_UINT32 = 13
    TYPE_ENUM = 14
    TYPE_SFIXED32 = 15
    TYPE_SFIXED64 = 16
    TYPE_SINT32 = 17
    TYPE_SINT64 = 18
    LABEL_OPTIONAL = 1
    LABEL_REQUIRED = 2
    LABEL_REPEATED = 3
    _M.FieldDescriptorProto = protobuf.Message(FieldDescriptorProto)
  end
  _M.FieldDescriptorProto.Type = FieldDescriptorProto.Type
  _M.FieldDescriptorProto.Label = FieldDescriptorProto.Label
end
do
  local EnumDescriptorProto = protobuf.Descriptor()
  local EnumDescriptorProto_name_FIELD = protobuf.FieldDescriptor()
  local EnumDescriptorProto_value_FIELD = protobuf.FieldDescriptor()
  local EnumDescriptorProto_options_FIELD = protobuf.FieldDescriptor()
  EnumDescriptorProto_name_FIELD.name = "name"
  EnumDescriptorProto_name_FIELD.full_name = "google.protobuf.EnumDescriptorProto_name"
  EnumDescriptorProto_name_FIELD.number = 1
  EnumDescriptorProto_name_FIELD.index = 0
  EnumDescriptorProto_name_FIELD.label = 1
  EnumDescriptorProto_name_FIELD.has_default_value = false
  EnumDescriptorProto_name_FIELD.default_value = ""
  EnumDescriptorProto_name_FIELD.type = 9
  EnumDescriptorProto_name_FIELD.cpp_type = 9
  EnumDescriptorProto_value_FIELD.name = "value"
  EnumDescriptorProto_value_FIELD.full_name = "google.protobuf.EnumDescriptorProto_value"
  EnumDescriptorProto_value_FIELD.number = 2
  EnumDescriptorProto_value_FIELD.index = 1
  EnumDescriptorProto_value_FIELD.label = 3
  EnumDescriptorProto_value_FIELD.has_default_value = false
  EnumDescriptorProto_value_FIELD.default_value = {}
  EnumDescriptorProto_value_FIELD.message_type = EnumValueDescriptorProto.GetDescriptor()
  EnumDescriptorProto_value_FIELD.type = 11
  EnumDescriptorProto_value_FIELD.cpp_type = 10
  EnumDescriptorProto_options_FIELD.name = "options"
  EnumDescriptorProto_options_FIELD.full_name = "google.protobuf.EnumDescriptorProto_options"
  EnumDescriptorProto_options_FIELD.number = 3
  EnumDescriptorProto_options_FIELD.index = 2
  EnumDescriptorProto_options_FIELD.label = 1
  EnumDescriptorProto_options_FIELD.has_default_value = false
  EnumDescriptorProto_options_FIELD.default_value = nil
  EnumDescriptorProto_options_FIELD.message_type = EnumOptions.GetDescriptor()
  EnumDescriptorProto_options_FIELD.type = 11
  EnumDescriptorProto_options_FIELD.cpp_type = 10
  EnumDescriptorProto.name = "EnumDescriptorProto"
  EnumDescriptorProto.full_name = "google.protobuf.EnumDescriptorProto"
  EnumDescriptorProto.nested_types = {}
  EnumDescriptorProto.enum_types = {}
  EnumDescriptorProto.fields = {
    EnumDescriptorProto_name_FIELD,
    EnumDescriptorProto_value_FIELD,
    EnumDescriptorProto_options_FIELD
  }
  EnumDescriptorProto.is_extendable = false
  EnumDescriptorProto.extensions = {}
  _M.EnumDescriptorProto = protobuf.Message(EnumDescriptorProto)
end
do
  local EnumValueDescriptorProto = protobuf.Descriptor()
  local EnumValueDescriptorProto_name_FIELD = protobuf.FieldDescriptor()
  local EnumValueDescriptorProto_number_FIELD = protobuf.FieldDescriptor()
  local EnumValueDescriptorProto_options_FIELD = protobuf.FieldDescriptor()
  EnumValueDescriptorProto_name_FIELD.name = "name"
  EnumValueDescriptorProto_name_FIELD.full_name = "google.protobuf.EnumValueDescriptorProto_name"
  EnumValueDescriptorProto_name_FIELD.number = 1
  EnumValueDescriptorProto_name_FIELD.index = 0
  EnumValueDescriptorProto_name_FIELD.label = 1
  EnumValueDescriptorProto_name_FIELD.has_default_value = false
  EnumValueDescriptorProto_name_FIELD.default_value = ""
  EnumValueDescriptorProto_name_FIELD.type = 9
  EnumValueDescriptorProto_name_FIELD.cpp_type = 9
  EnumValueDescriptorProto_number_FIELD.name = "number"
  EnumValueDescriptorProto_number_FIELD.full_name = "google.protobuf.EnumValueDescriptorProto_number"
  EnumValueDescriptorProto_number_FIELD.number = 2
  EnumValueDescriptorProto_number_FIELD.index = 1
  EnumValueDescriptorProto_number_FIELD.label = 1
  EnumValueDescriptorProto_number_FIELD.has_default_value = false
  EnumValueDescriptorProto_number_FIELD.default_value = 0
  EnumValueDescriptorProto_number_FIELD.type = 5
  EnumValueDescriptorProto_number_FIELD.cpp_type = 1
  EnumValueDescriptorProto_options_FIELD.name = "options"
  EnumValueDescriptorProto_options_FIELD.full_name = "google.protobuf.EnumValueDescriptorProto_options"
  EnumValueDescriptorProto_options_FIELD.number = 3
  EnumValueDescriptorProto_options_FIELD.index = 2
  EnumValueDescriptorProto_options_FIELD.label = 1
  EnumValueDescriptorProto_options_FIELD.has_default_value = false
  EnumValueDescriptorProto_options_FIELD.default_value = nil
  EnumValueDescriptorProto_options_FIELD.message_type = EnumValueOptions.GetDescriptor()
  EnumValueDescriptorProto_options_FIELD.type = 11
  EnumValueDescriptorProto_options_FIELD.cpp_type = 10
  EnumValueDescriptorProto.name = "EnumValueDescriptorProto"
  EnumValueDescriptorProto.full_name = "google.protobuf.EnumValueDescriptorProto"
  EnumValueDescriptorProto.nested_types = {}
  EnumValueDescriptorProto.enum_types = {}
  EnumValueDescriptorProto.fields = {
    EnumValueDescriptorProto_name_FIELD,
    EnumValueDescriptorProto_number_FIELD,
    EnumValueDescriptorProto_options_FIELD
  }
  EnumValueDescriptorProto.is_extendable = false
  EnumValueDescriptorProto.extensions = {}
  _M.EnumValueDescriptorProto = protobuf.Message(EnumValueDescriptorProto)
end
do
  local ServiceDescriptorProto = protobuf.Descriptor()
  local ServiceDescriptorProto_name_FIELD = protobuf.FieldDescriptor()
  local ServiceDescriptorProto_method_FIELD = protobuf.FieldDescriptor()
  local ServiceDescriptorProto_options_FIELD = protobuf.FieldDescriptor()
  ServiceDescriptorProto_name_FIELD.name = "name"
  ServiceDescriptorProto_name_FIELD.full_name = "google.protobuf.ServiceDescriptorProto_name"
  ServiceDescriptorProto_name_FIELD.number = 1
  ServiceDescriptorProto_name_FIELD.index = 0
  ServiceDescriptorProto_name_FIELD.label = 1
  ServiceDescriptorProto_name_FIELD.has_default_value = false
  ServiceDescriptorProto_name_FIELD.default_value = ""
  ServiceDescriptorProto_name_FIELD.type = 9
  ServiceDescriptorProto_name_FIELD.cpp_type = 9
  ServiceDescriptorProto_method_FIELD.name = "method"
  ServiceDescriptorProto_method_FIELD.full_name = "google.protobuf.ServiceDescriptorProto_method"
  ServiceDescriptorProto_method_FIELD.number = 2
  ServiceDescriptorProto_method_FIELD.index = 1
  ServiceDescriptorProto_method_FIELD.label = 3
  ServiceDescriptorProto_method_FIELD.has_default_value = false
  ServiceDescriptorProto_method_FIELD.default_value = {}
  ServiceDescriptorProto_method_FIELD.message_type = MethodDescriptorProto.GetDescriptor()
  ServiceDescriptorProto_method_FIELD.type = 11
  ServiceDescriptorProto_method_FIELD.cpp_type = 10
  ServiceDescriptorProto_options_FIELD.name = "options"
  ServiceDescriptorProto_options_FIELD.full_name = "google.protobuf.ServiceDescriptorProto_options"
  ServiceDescriptorProto_options_FIELD.number = 3
  ServiceDescriptorProto_options_FIELD.index = 2
  ServiceDescriptorProto_options_FIELD.label = 1
  ServiceDescriptorProto_options_FIELD.has_default_value = false
  ServiceDescriptorProto_options_FIELD.default_value = nil
  ServiceDescriptorProto_options_FIELD.message_type = ServiceOptions.GetDescriptor()
  ServiceDescriptorProto_options_FIELD.type = 11
  ServiceDescriptorProto_options_FIELD.cpp_type = 10
  ServiceDescriptorProto.name = "ServiceDescriptorProto"
  ServiceDescriptorProto.full_name = "google.protobuf.ServiceDescriptorProto"
  ServiceDescriptorProto.nested_types = {}
  ServiceDescriptorProto.enum_types = {}
  ServiceDescriptorProto.fields = {
    ServiceDescriptorProto_name_FIELD,
    ServiceDescriptorProto_method_FIELD,
    ServiceDescriptorProto_options_FIELD
  }
  ServiceDescriptorProto.is_extendable = false
  ServiceDescriptorProto.extensions = {}
  _M.ServiceDescriptorProto = protobuf.Message(ServiceDescriptorProto)
end
do
  local MethodDescriptorProto = protobuf.Descriptor()
  local MethodDescriptorProto_name_FIELD = protobuf.FieldDescriptor()
  local MethodDescriptorProto_input_type_FIELD = protobuf.FieldDescriptor()
  local MethodDescriptorProto_output_type_FIELD = protobuf.FieldDescriptor()
  local MethodDescriptorProto_options_FIELD = protobuf.FieldDescriptor()
  MethodDescriptorProto_name_FIELD.name = "name"
  MethodDescriptorProto_name_FIELD.full_name = "google.protobuf.MethodDescriptorProto_name"
  MethodDescriptorProto_name_FIELD.number = 1
  MethodDescriptorProto_name_FIELD.index = 0
  MethodDescriptorProto_name_FIELD.label = 1
  MethodDescriptorProto_name_FIELD.has_default_value = false
  MethodDescriptorProto_name_FIELD.default_value = ""
  MethodDescriptorProto_name_FIELD.type = 9
  MethodDescriptorProto_name_FIELD.cpp_type = 9
  MethodDescriptorProto_input_type_FIELD.name = "input_type"
  MethodDescriptorProto_input_type_FIELD.full_name = "google.protobuf.MethodDescriptorProto_input_type"
  MethodDescriptorProto_input_type_FIELD.number = 2
  MethodDescriptorProto_input_type_FIELD.index = 1
  MethodDescriptorProto_input_type_FIELD.label = 1
  MethodDescriptorProto_input_type_FIELD.has_default_value = false
  MethodDescriptorProto_input_type_FIELD.default_value = ""
  MethodDescriptorProto_input_type_FIELD.type = 9
  MethodDescriptorProto_input_type_FIELD.cpp_type = 9
  MethodDescriptorProto_output_type_FIELD.name = "output_type"
  MethodDescriptorProto_output_type_FIELD.full_name = "google.protobuf.MethodDescriptorProto_output_type"
  MethodDescriptorProto_output_type_FIELD.number = 3
  MethodDescriptorProto_output_type_FIELD.index = 2
  MethodDescriptorProto_output_type_FIELD.label = 1
  MethodDescriptorProto_output_type_FIELD.has_default_value = false
  MethodDescriptorProto_output_type_FIELD.default_value = ""
  MethodDescriptorProto_output_type_FIELD.type = 9
  MethodDescriptorProto_output_type_FIELD.cpp_type = 9
  MethodDescriptorProto_options_FIELD.name = "options"
  MethodDescriptorProto_options_FIELD.full_name = "google.protobuf.MethodDescriptorProto_options"
  MethodDescriptorProto_options_FIELD.number = 4
  MethodDescriptorProto_options_FIELD.index = 3
  MethodDescriptorProto_options_FIELD.label = 1
  MethodDescriptorProto_options_FIELD.has_default_value = false
  MethodDescriptorProto_options_FIELD.default_value = nil
  MethodDescriptorProto_options_FIELD.message_type = MethodOptions.GetDescriptor()
  MethodDescriptorProto_options_FIELD.type = 11
  MethodDescriptorProto_options_FIELD.cpp_type = 10
  MethodDescriptorProto.name = "MethodDescriptorProto"
  MethodDescriptorProto.full_name = "google.protobuf.MethodDescriptorProto"
  MethodDescriptorProto.nested_types = {}
  MethodDescriptorProto.enum_types = {}
  MethodDescriptorProto.fields = {
    MethodDescriptorProto_name_FIELD,
    MethodDescriptorProto_input_type_FIELD,
    MethodDescriptorProto_output_type_FIELD,
    MethodDescriptorProto_options_FIELD
  }
  MethodDescriptorProto.is_extendable = false
  MethodDescriptorProto.extensions = {}
  _M.MethodDescriptorProto = protobuf.Message(MethodDescriptorProto)
end
do
  local FileOptions = protobuf.Descriptor()
  FileOptions.OptimizeMode = protobuf.EnumDescriptor()
  FileOptions.OptimizeMode_SPEED_ENUM = protobuf.EnumValueDescriptor()
  FileOptions.OptimizeMode_CODE_SIZE_ENUM = protobuf.EnumValueDescriptor()
  FileOptions.OptimizeMode_LITE_RUNTIME_ENUM = protobuf.EnumValueDescriptor()
  do
    local FileOptions_java_package_FIELD = protobuf.FieldDescriptor()
    local FileOptions_java_outer_classname_FIELD = protobuf.FieldDescriptor()
    local FileOptions_java_multiple_files_FIELD = protobuf.FieldDescriptor()
    local FileOptions_java_generate_equals_and_hash_FIELD = protobuf.FieldDescriptor()
    local FileOptions_optimize_for_FIELD = protobuf.FieldDescriptor()
    local FileOptions_go_package_FIELD = protobuf.FieldDescriptor()
    local FileOptions_cc_generic_services_FIELD = protobuf.FieldDescriptor()
    local FileOptions_java_generic_services_FIELD = protobuf.FieldDescriptor()
    local FileOptions_py_generic_services_FIELD = protobuf.FieldDescriptor()
    local FileOptions_uninterpreted_option_FIELD = protobuf.FieldDescriptor()
    FileOptions.OptimizeMode_SPEED_ENUM.name = "SPEED"
    FileOptions.OptimizeMode_SPEED_ENUM.index = 0
    FileOptions.OptimizeMode_SPEED_ENUM.number = 1
    FileOptions.OptimizeMode_CODE_SIZE_ENUM.name = "CODE_SIZE"
    FileOptions.OptimizeMode_CODE_SIZE_ENUM.index = 1
    FileOptions.OptimizeMode_CODE_SIZE_ENUM.number = 2
    FileOptions.OptimizeMode_LITE_RUNTIME_ENUM.name = "LITE_RUNTIME"
    FileOptions.OptimizeMode_LITE_RUNTIME_ENUM.index = 2
    FileOptions.OptimizeMode_LITE_RUNTIME_ENUM.number = 3
    FileOptions.OptimizeMode.name = "OptimizeMode"
    FileOptions.OptimizeMode.full_name = "google.protobuf.FileOptions.OptimizeMode"
    FileOptions.OptimizeMode.values = {
      FileOptions.OptimizeMode_SPEED_ENUM,
      FileOptions.OptimizeMode_CODE_SIZE_ENUM,
      FileOptions.OptimizeMode_LITE_RUNTIME_ENUM
    }
    FileOptions_java_package_FIELD.name = "java_package"
    FileOptions_java_package_FIELD.full_name = "google.protobuf.FileOptions_java_package"
    FileOptions_java_package_FIELD.number = 1
    FileOptions_java_package_FIELD.index = 0
    FileOptions_java_package_FIELD.label = 1
    FileOptions_java_package_FIELD.has_default_value = false
    FileOptions_java_package_FIELD.default_value = ""
    FileOptions_java_package_FIELD.type = 9
    FileOptions_java_package_FIELD.cpp_type = 9
    FileOptions_java_outer_classname_FIELD.name = "java_outer_classname"
    FileOptions_java_outer_classname_FIELD.full_name = "google.protobuf.FileOptions_java_outer_classname"
    FileOptions_java_outer_classname_FIELD.number = 8
    FileOptions_java_outer_classname_FIELD.index = 1
    FileOptions_java_outer_classname_FIELD.label = 1
    FileOptions_java_outer_classname_FIELD.has_default_value = false
    FileOptions_java_outer_classname_FIELD.default_value = ""
    FileOptions_java_outer_classname_FIELD.type = 9
    FileOptions_java_outer_classname_FIELD.cpp_type = 9
    FileOptions_java_multiple_files_FIELD.name = "java_multiple_files"
    FileOptions_java_multiple_files_FIELD.full_name = "google.protobuf.FileOptions_java_multiple_files"
    FileOptions_java_multiple_files_FIELD.number = 10
    FileOptions_java_multiple_files_FIELD.index = 2
    FileOptions_java_multiple_files_FIELD.label = 1
    FileOptions_java_multiple_files_FIELD.has_default_value = true
    FileOptions_java_multiple_files_FIELD.default_value = false
    FileOptions_java_multiple_files_FIELD.type = 8
    FileOptions_java_multiple_files_FIELD.cpp_type = 7
    FileOptions_java_generate_equals_and_hash_FIELD.name = "java_generate_equals_and_hash"
    FileOptions_java_generate_equals_and_hash_FIELD.full_name = "google.protobuf.FileOptions_java_generate_equals_and_hash"
    FileOptions_java_generate_equals_and_hash_FIELD.number = 20
    FileOptions_java_generate_equals_and_hash_FIELD.index = 3
    FileOptions_java_generate_equals_and_hash_FIELD.label = 1
    FileOptions_java_generate_equals_and_hash_FIELD.has_default_value = true
    FileOptions_java_generate_equals_and_hash_FIELD.default_value = false
    FileOptions_java_generate_equals_and_hash_FIELD.type = 8
    FileOptions_java_generate_equals_and_hash_FIELD.cpp_type = 7
    FileOptions_optimize_for_FIELD.name = "optimize_for"
    FileOptions_optimize_for_FIELD.full_name = "google.protobuf.FileOptions_optimize_for"
    FileOptions_optimize_for_FIELD.number = 9
    FileOptions_optimize_for_FIELD.index = 4
    FileOptions_optimize_for_FIELD.label = 1
    FileOptions_optimize_for_FIELD.has_default_value = true
    FileOptions_optimize_for_FIELD.default_value = SPEED
    FileOptions_optimize_for_FIELD.enum_type = FileOptions.OptimizeMode
    FileOptions_optimize_for_FIELD.type = 14
    FileOptions_optimize_for_FIELD.cpp_type = 8
    FileOptions_go_package_FIELD.name = "go_package"
    FileOptions_go_package_FIELD.full_name = "google.protobuf.FileOptions_go_package"
    FileOptions_go_package_FIELD.number = 11
    FileOptions_go_package_FIELD.index = 5
    FileOptions_go_package_FIELD.label = 1
    FileOptions_go_package_FIELD.has_default_value = false
    FileOptions_go_package_FIELD.default_value = ""
    FileOptions_go_package_FIELD.type = 9
    FileOptions_go_package_FIELD.cpp_type = 9
    FileOptions_cc_generic_services_FIELD.name = "cc_generic_services"
    FileOptions_cc_generic_services_FIELD.full_name = "google.protobuf.FileOptions_cc_generic_services"
    FileOptions_cc_generic_services_FIELD.number = 16
    FileOptions_cc_generic_services_FIELD.index = 6
    FileOptions_cc_generic_services_FIELD.label = 1
    FileOptions_cc_generic_services_FIELD.has_default_value = true
    FileOptions_cc_generic_services_FIELD.default_value = false
    FileOptions_cc_generic_services_FIELD.type = 8
    FileOptions_cc_generic_services_FIELD.cpp_type = 7
    FileOptions_java_generic_services_FIELD.name = "java_generic_services"
    FileOptions_java_generic_services_FIELD.full_name = "google.protobuf.FileOptions_java_generic_services"
    FileOptions_java_generic_services_FIELD.number = 17
    FileOptions_java_generic_services_FIELD.index = 7
    FileOptions_java_generic_services_FIELD.label = 1
    FileOptions_java_generic_services_FIELD.has_default_value = true
    FileOptions_java_generic_services_FIELD.default_value = false
    FileOptions_java_generic_services_FIELD.type = 8
    FileOptions_java_generic_services_FIELD.cpp_type = 7
    FileOptions_py_generic_services_FIELD.name = "py_generic_services"
    FileOptions_py_generic_services_FIELD.full_name = "google.protobuf.FileOptions_py_generic_services"
    FileOptions_py_generic_services_FIELD.number = 18
    FileOptions_py_generic_services_FIELD.index = 8
    FileOptions_py_generic_services_FIELD.label = 1
    FileOptions_py_generic_services_FIELD.has_default_value = true
    FileOptions_py_generic_services_FIELD.default_value = false
    FileOptions_py_generic_services_FIELD.type = 8
    FileOptions_py_generic_services_FIELD.cpp_type = 7
    FileOptions_uninterpreted_option_FIELD.name = "uninterpreted_option"
    FileOptions_uninterpreted_option_FIELD.full_name = "google.protobuf.FileOptions_uninterpreted_option"
    FileOptions_uninterpreted_option_FIELD.number = 999
    FileOptions_uninterpreted_option_FIELD.index = 9
    FileOptions_uninterpreted_option_FIELD.label = 3
    FileOptions_uninterpreted_option_FIELD.has_default_value = false
    FileOptions_uninterpreted_option_FIELD.default_value = {}
    FileOptions_uninterpreted_option_FIELD.message_type = UninterpretedOption.GetDescriptor()
    FileOptions_uninterpreted_option_FIELD.type = 11
    FileOptions_uninterpreted_option_FIELD.cpp_type = 10
    FileOptions.name = "FileOptions"
    FileOptions.full_name = "google.protobuf.FileOptions"
    FileOptions.nested_types = {}
    FileOptions.enum_types = {
      FileOptions.OptimizeMode
    }
    FileOptions.fields = {
      FileOptions_java_package_FIELD,
      FileOptions_java_outer_classname_FIELD,
      FileOptions_java_multiple_files_FIELD,
      FileOptions_java_generate_equals_and_hash_FIELD,
      FileOptions_optimize_for_FIELD,
      FileOptions_go_package_FIELD,
      FileOptions_cc_generic_services_FIELD,
      FileOptions_java_generic_services_FIELD,
      FileOptions_py_generic_services_FIELD,
      FileOptions_uninterpreted_option_FIELD
    }
    FileOptions.is_extendable = true
    FileOptions.extensions = {}
    SPEED = 1
    CODE_SIZE = 2
    LITE_RUNTIME = 3
    _M.FileOptions = protobuf.Message(FileOptions)
  end
  _M.FileOptions.OptimizeMode = FileOptions.OptimizeMode
end
do
  local MessageOptions = protobuf.Descriptor()
  local MessageOptions_message_set_wire_format_FIELD = protobuf.FieldDescriptor()
  local MessageOptions_no_standard_descriptor_accessor_FIELD = protobuf.FieldDescriptor()
  local MessageOptions_uninterpreted_option_FIELD = protobuf.FieldDescriptor()
  MessageOptions_message_set_wire_format_FIELD.name = "message_set_wire_format"
  MessageOptions_message_set_wire_format_FIELD.full_name = "google.protobuf.MessageOptions_message_set_wire_format"
  MessageOptions_message_set_wire_format_FIELD.number = 1
  MessageOptions_message_set_wire_format_FIELD.index = 0
  MessageOptions_message_set_wire_format_FIELD.label = 1
  MessageOptions_message_set_wire_format_FIELD.has_default_value = true
  MessageOptions_message_set_wire_format_FIELD.default_value = false
  MessageOptions_message_set_wire_format_FIELD.type = 8
  MessageOptions_message_set_wire_format_FIELD.cpp_type = 7
  MessageOptions_no_standard_descriptor_accessor_FIELD.name = "no_standard_descriptor_accessor"
  MessageOptions_no_standard_descriptor_accessor_FIELD.full_name = "google.protobuf.MessageOptions_no_standard_descriptor_accessor"
  MessageOptions_no_standard_descriptor_accessor_FIELD.number = 2
  MessageOptions_no_standard_descriptor_accessor_FIELD.index = 1
  MessageOptions_no_standard_descriptor_accessor_FIELD.label = 1
  MessageOptions_no_standard_descriptor_accessor_FIELD.has_default_value = true
  MessageOptions_no_standard_descriptor_accessor_FIELD.default_value = false
  MessageOptions_no_standard_descriptor_accessor_FIELD.type = 8
  MessageOptions_no_standard_descriptor_accessor_FIELD.cpp_type = 7
  MessageOptions_uninterpreted_option_FIELD.name = "uninterpreted_option"
  MessageOptions_uninterpreted_option_FIELD.full_name = "google.protobuf.MessageOptions_uninterpreted_option"
  MessageOptions_uninterpreted_option_FIELD.number = 999
  MessageOptions_uninterpreted_option_FIELD.index = 2
  MessageOptions_uninterpreted_option_FIELD.label = 3
  MessageOptions_uninterpreted_option_FIELD.has_default_value = false
  MessageOptions_uninterpreted_option_FIELD.default_value = {}
  MessageOptions_uninterpreted_option_FIELD.message_type = UninterpretedOption.GetDescriptor()
  MessageOptions_uninterpreted_option_FIELD.type = 11
  MessageOptions_uninterpreted_option_FIELD.cpp_type = 10
  MessageOptions.name = "MessageOptions"
  MessageOptions.full_name = "google.protobuf.MessageOptions"
  MessageOptions.nested_types = {}
  MessageOptions.enum_types = {}
  MessageOptions.fields = {
    MessageOptions_message_set_wire_format_FIELD,
    MessageOptions_no_standard_descriptor_accessor_FIELD,
    MessageOptions_uninterpreted_option_FIELD
  }
  MessageOptions.is_extendable = true
  MessageOptions.extensions = {}
  _M.MessageOptions = protobuf.Message(MessageOptions)
end
do
  local FieldOptions = protobuf.Descriptor()
  FieldOptions.CType = protobuf.EnumDescriptor()
  FieldOptions.CType_STRING_ENUM = protobuf.EnumValueDescriptor()
  FieldOptions.CType_CORD_ENUM = protobuf.EnumValueDescriptor()
  FieldOptions.CType_STRING_PIECE_ENUM = protobuf.EnumValueDescriptor()
  do
    local FieldOptions_ctype_FIELD = protobuf.FieldDescriptor()
    local FieldOptions_packed_FIELD = protobuf.FieldDescriptor()
    local FieldOptions_lazy_FIELD = protobuf.FieldDescriptor()
    local FieldOptions_deprecated_FIELD = protobuf.FieldDescriptor()
    local FieldOptions_experimental_map_key_FIELD = protobuf.FieldDescriptor()
    local FieldOptions_weak_FIELD = protobuf.FieldDescriptor()
    local FieldOptions_uninterpreted_option_FIELD = protobuf.FieldDescriptor()
    FieldOptions.CType_STRING_ENUM.name = "STRING"
    FieldOptions.CType_STRING_ENUM.index = 0
    FieldOptions.CType_STRING_ENUM.number = 0
    FieldOptions.CType_CORD_ENUM.name = "CORD"
    FieldOptions.CType_CORD_ENUM.index = 1
    FieldOptions.CType_CORD_ENUM.number = 1
    FieldOptions.CType_STRING_PIECE_ENUM.name = "STRING_PIECE"
    FieldOptions.CType_STRING_PIECE_ENUM.index = 2
    FieldOptions.CType_STRING_PIECE_ENUM.number = 2
    FieldOptions.CType.name = "CType"
    FieldOptions.CType.full_name = "google.protobuf.FieldOptions.CType"
    FieldOptions.CType.values = {
      FieldOptions.CType_STRING_ENUM,
      FieldOptions.CType_CORD_ENUM,
      FieldOptions.CType_STRING_PIECE_ENUM
    }
    FieldOptions_ctype_FIELD.name = "ctype"
    FieldOptions_ctype_FIELD.full_name = "google.protobuf.FieldOptions_ctype"
    FieldOptions_ctype_FIELD.number = 1
    FieldOptions_ctype_FIELD.index = 0
    FieldOptions_ctype_FIELD.label = 1
    FieldOptions_ctype_FIELD.has_default_value = true
    FieldOptions_ctype_FIELD.default_value = STRING
    FieldOptions_ctype_FIELD.enum_type = FieldOptions.CType
    FieldOptions_ctype_FIELD.type = 14
    FieldOptions_ctype_FIELD.cpp_type = 8
    FieldOptions_packed_FIELD.name = "packed"
    FieldOptions_packed_FIELD.full_name = "google.protobuf.FieldOptions_packed"
    FieldOptions_packed_FIELD.number = 2
    FieldOptions_packed_FIELD.index = 1
    FieldOptions_packed_FIELD.label = 1
    FieldOptions_packed_FIELD.has_default_value = false
    FieldOptions_packed_FIELD.default_value = false
    FieldOptions_packed_FIELD.type = 8
    FieldOptions_packed_FIELD.cpp_type = 7
    FieldOptions_lazy_FIELD.name = "lazy"
    FieldOptions_lazy_FIELD.full_name = "google.protobuf.FieldOptions_lazy"
    FieldOptions_lazy_FIELD.number = 5
    FieldOptions_lazy_FIELD.index = 2
    FieldOptions_lazy_FIELD.label = 1
    FieldOptions_lazy_FIELD.has_default_value = true
    FieldOptions_lazy_FIELD.default_value = false
    FieldOptions_lazy_FIELD.type = 8
    FieldOptions_lazy_FIELD.cpp_type = 7
    FieldOptions_deprecated_FIELD.name = "deprecated"
    FieldOptions_deprecated_FIELD.full_name = "google.protobuf.FieldOptions_deprecated"
    FieldOptions_deprecated_FIELD.number = 3
    FieldOptions_deprecated_FIELD.index = 3
    FieldOptions_deprecated_FIELD.label = 1
    FieldOptions_deprecated_FIELD.has_default_value = true
    FieldOptions_deprecated_FIELD.default_value = false
    FieldOptions_deprecated_FIELD.type = 8
    FieldOptions_deprecated_FIELD.cpp_type = 7
    FieldOptions_experimental_map_key_FIELD.name = "experimental_map_key"
    FieldOptions_experimental_map_key_FIELD.full_name = "google.protobuf.FieldOptions_experimental_map_key"
    FieldOptions_experimental_map_key_FIELD.number = 9
    FieldOptions_experimental_map_key_FIELD.index = 4
    FieldOptions_experimental_map_key_FIELD.label = 1
    FieldOptions_experimental_map_key_FIELD.has_default_value = false
    FieldOptions_experimental_map_key_FIELD.default_value = ""
    FieldOptions_experimental_map_key_FIELD.type = 9
    FieldOptions_experimental_map_key_FIELD.cpp_type = 9
    FieldOptions_weak_FIELD.name = "weak"
    FieldOptions_weak_FIELD.full_name = "google.protobuf.FieldOptions_weak"
    FieldOptions_weak_FIELD.number = 10
    FieldOptions_weak_FIELD.index = 5
    FieldOptions_weak_FIELD.label = 1
    FieldOptions_weak_FIELD.has_default_value = true
    FieldOptions_weak_FIELD.default_value = false
    FieldOptions_weak_FIELD.type = 8
    FieldOptions_weak_FIELD.cpp_type = 7
    FieldOptions_uninterpreted_option_FIELD.name = "uninterpreted_option"
    FieldOptions_uninterpreted_option_FIELD.full_name = "google.protobuf.FieldOptions_uninterpreted_option"
    FieldOptions_uninterpreted_option_FIELD.number = 999
    FieldOptions_uninterpreted_option_FIELD.index = 6
    FieldOptions_uninterpreted_option_FIELD.label = 3
    FieldOptions_uninterpreted_option_FIELD.has_default_value = false
    FieldOptions_uninterpreted_option_FIELD.default_value = {}
    FieldOptions_uninterpreted_option_FIELD.message_type = UninterpretedOption.GetDescriptor()
    FieldOptions_uninterpreted_option_FIELD.type = 11
    FieldOptions_uninterpreted_option_FIELD.cpp_type = 10
    FieldOptions.name = "FieldOptions"
    FieldOptions.full_name = "google.protobuf.FieldOptions"
    FieldOptions.nested_types = {}
    FieldOptions.enum_types = {
      FieldOptions.CType
    }
    FieldOptions.fields = {
      FieldOptions_ctype_FIELD,
      FieldOptions_packed_FIELD,
      FieldOptions_lazy_FIELD,
      FieldOptions_deprecated_FIELD,
      FieldOptions_experimental_map_key_FIELD,
      FieldOptions_weak_FIELD,
      FieldOptions_uninterpreted_option_FIELD
    }
    FieldOptions.is_extendable = true
    FieldOptions.extensions = {}
    STRING = 0
    CORD = 1
    STRING_PIECE = 2
    _M.FieldOptions = protobuf.Message(FieldOptions)
  end
  _M.FieldOptions.CType = FieldOptions.CType
end
do
  local EnumOptions = protobuf.Descriptor()
  local EnumOptions_allow_alias_FIELD = protobuf.FieldDescriptor()
  local EnumOptions_uninterpreted_option_FIELD = protobuf.FieldDescriptor()
  EnumOptions_allow_alias_FIELD.name = "allow_alias"
  EnumOptions_allow_alias_FIELD.full_name = "google.protobuf.EnumOptions_allow_alias"
  EnumOptions_allow_alias_FIELD.number = 2
  EnumOptions_allow_alias_FIELD.index = 0
  EnumOptions_allow_alias_FIELD.label = 1
  EnumOptions_allow_alias_FIELD.has_default_value = true
  EnumOptions_allow_alias_FIELD.default_value = true
  EnumOptions_allow_alias_FIELD.type = 8
  EnumOptions_allow_alias_FIELD.cpp_type = 7
  EnumOptions_uninterpreted_option_FIELD.name = "uninterpreted_option"
  EnumOptions_uninterpreted_option_FIELD.full_name = "google.protobuf.EnumOptions_uninterpreted_option"
  EnumOptions_uninterpreted_option_FIELD.number = 999
  EnumOptions_uninterpreted_option_FIELD.index = 1
  EnumOptions_uninterpreted_option_FIELD.label = 3
  EnumOptions_uninterpreted_option_FIELD.has_default_value = false
  EnumOptions_uninterpreted_option_FIELD.default_value = {}
  EnumOptions_uninterpreted_option_FIELD.message_type = UninterpretedOption.GetDescriptor()
  EnumOptions_uninterpreted_option_FIELD.type = 11
  EnumOptions_uninterpreted_option_FIELD.cpp_type = 10
  EnumOptions.name = "EnumOptions"
  EnumOptions.full_name = "google.protobuf.EnumOptions"
  EnumOptions.nested_types = {}
  EnumOptions.enum_types = {}
  EnumOptions.fields = {EnumOptions_allow_alias_FIELD, EnumOptions_uninterpreted_option_FIELD}
  EnumOptions.is_extendable = true
  EnumOptions.extensions = {}
  _M.EnumOptions = protobuf.Message(EnumOptions)
end
do
  local EnumValueOptions = protobuf.Descriptor()
  local EnumValueOptions_uninterpreted_option_FIELD = protobuf.FieldDescriptor()
  EnumValueOptions_uninterpreted_option_FIELD.name = "uninterpreted_option"
  EnumValueOptions_uninterpreted_option_FIELD.full_name = "google.protobuf.EnumValueOptions_uninterpreted_option"
  EnumValueOptions_uninterpreted_option_FIELD.number = 999
  EnumValueOptions_uninterpreted_option_FIELD.index = 0
  EnumValueOptions_uninterpreted_option_FIELD.label = 3
  EnumValueOptions_uninterpreted_option_FIELD.has_default_value = false
  EnumValueOptions_uninterpreted_option_FIELD.default_value = {}
  EnumValueOptions_uninterpreted_option_FIELD.message_type = UninterpretedOption.GetDescriptor()
  EnumValueOptions_uninterpreted_option_FIELD.type = 11
  EnumValueOptions_uninterpreted_option_FIELD.cpp_type = 10
  EnumValueOptions.name = "EnumValueOptions"
  EnumValueOptions.full_name = "google.protobuf.EnumValueOptions"
  EnumValueOptions.nested_types = {}
  EnumValueOptions.enum_types = {}
  EnumValueOptions.fields = {EnumValueOptions_uninterpreted_option_FIELD}
  EnumValueOptions.is_extendable = true
  EnumValueOptions.extensions = {}
  _M.EnumValueOptions = protobuf.Message(EnumValueOptions)
end
do
  local ServiceOptions = protobuf.Descriptor()
  local ServiceOptions_uninterpreted_option_FIELD = protobuf.FieldDescriptor()
  ServiceOptions_uninterpreted_option_FIELD.name = "uninterpreted_option"
  ServiceOptions_uninterpreted_option_FIELD.full_name = "google.protobuf.ServiceOptions_uninterpreted_option"
  ServiceOptions_uninterpreted_option_FIELD.number = 999
  ServiceOptions_uninterpreted_option_FIELD.index = 0
  ServiceOptions_uninterpreted_option_FIELD.label = 3
  ServiceOptions_uninterpreted_option_FIELD.has_default_value = false
  ServiceOptions_uninterpreted_option_FIELD.default_value = {}
  ServiceOptions_uninterpreted_option_FIELD.message_type = UninterpretedOption.GetDescriptor()
  ServiceOptions_uninterpreted_option_FIELD.type = 11
  ServiceOptions_uninterpreted_option_FIELD.cpp_type = 10
  ServiceOptions.name = "ServiceOptions"
  ServiceOptions.full_name = "google.protobuf.ServiceOptions"
  ServiceOptions.nested_types = {}
  ServiceOptions.enum_types = {}
  ServiceOptions.fields = {ServiceOptions_uninterpreted_option_FIELD}
  ServiceOptions.is_extendable = true
  ServiceOptions.extensions = {}
  _M.ServiceOptions = protobuf.Message(ServiceOptions)
end
do
  local MethodOptions = protobuf.Descriptor()
  local MethodOptions_uninterpreted_option_FIELD = protobuf.FieldDescriptor()
  MethodOptions_uninterpreted_option_FIELD.name = "uninterpreted_option"
  MethodOptions_uninterpreted_option_FIELD.full_name = "google.protobuf.MethodOptions_uninterpreted_option"
  MethodOptions_uninterpreted_option_FIELD.number = 999
  MethodOptions_uninterpreted_option_FIELD.index = 0
  MethodOptions_uninterpreted_option_FIELD.label = 3
  MethodOptions_uninterpreted_option_FIELD.has_default_value = false
  MethodOptions_uninterpreted_option_FIELD.default_value = {}
  MethodOptions_uninterpreted_option_FIELD.message_type = UninterpretedOption.GetDescriptor()
  MethodOptions_uninterpreted_option_FIELD.type = 11
  MethodOptions_uninterpreted_option_FIELD.cpp_type = 10
  MethodOptions.name = "MethodOptions"
  MethodOptions.full_name = "google.protobuf.MethodOptions"
  MethodOptions.nested_types = {}
  MethodOptions.enum_types = {}
  MethodOptions.fields = {MethodOptions_uninterpreted_option_FIELD}
  MethodOptions.is_extendable = true
  MethodOptions.extensions = {}
  _M.MethodOptions = protobuf.Message(MethodOptions)
end
do
  local UninterpretedOption = protobuf.Descriptor()
  UninterpretedOption.NamePart = protobuf.Descriptor()
  UninterpretedOption.NamePart_name_part_FIELD = protobuf.FieldDescriptor()
  UninterpretedOption.NamePart_is_extension_FIELD = protobuf.FieldDescriptor()
  do
    local UninterpretedOption_name_FIELD = protobuf.FieldDescriptor()
    local UninterpretedOption_identifier_value_FIELD = protobuf.FieldDescriptor()
    local UninterpretedOption_positive_int_value_FIELD = protobuf.FieldDescriptor()
    local UninterpretedOption_negative_int_value_FIELD = protobuf.FieldDescriptor()
    local UninterpretedOption_double_value_FIELD = protobuf.FieldDescriptor()
    local UninterpretedOption_string_value_FIELD = protobuf.FieldDescriptor()
    local UninterpretedOption_aggregate_value_FIELD = protobuf.FieldDescriptor()
    UninterpretedOption.NamePart_name_part_FIELD.name = "name_part"
    UninterpretedOption.NamePart_name_part_FIELD.full_name = "google.protobuf.UninterpretedOption.NamePart_name_part"
    UninterpretedOption.NamePart_name_part_FIELD.number = 1
    UninterpretedOption.NamePart_name_part_FIELD.index = 0
    UninterpretedOption.NamePart_name_part_FIELD.label = 2
    UninterpretedOption.NamePart_name_part_FIELD.has_default_value = false
    UninterpretedOption.NamePart_name_part_FIELD.default_value = ""
    UninterpretedOption.NamePart_name_part_FIELD.type = 9
    UninterpretedOption.NamePart_name_part_FIELD.cpp_type = 9
    UninterpretedOption.NamePart_is_extension_FIELD.name = "is_extension"
    UninterpretedOption.NamePart_is_extension_FIELD.full_name = "google.protobuf.UninterpretedOption.NamePart_is_extension"
    UninterpretedOption.NamePart_is_extension_FIELD.number = 2
    UninterpretedOption.NamePart_is_extension_FIELD.index = 1
    UninterpretedOption.NamePart_is_extension_FIELD.label = 2
    UninterpretedOption.NamePart_is_extension_FIELD.has_default_value = false
    UninterpretedOption.NamePart_is_extension_FIELD.default_value = false
    UninterpretedOption.NamePart_is_extension_FIELD.type = 8
    UninterpretedOption.NamePart_is_extension_FIELD.cpp_type = 7
    UninterpretedOption.NamePart.name = "NamePart"
    UninterpretedOption.NamePart.full_name = "google.protobuf.UninterpretedOption.NamePart"
    UninterpretedOption.NamePart.nested_types = {}
    UninterpretedOption.NamePart.enum_types = {}
    UninterpretedOption.NamePart.fields = {
      UninterpretedOption.NamePart_name_part_FIELD,
      UninterpretedOption.NamePart_is_extension_FIELD
    }
    UninterpretedOption.NamePart.is_extendable = false
    UninterpretedOption.NamePart.extensions = {}
    UninterpretedOption.NamePart.containing_type = UninterpretedOption
    UninterpretedOption_name_FIELD.name = "name"
    UninterpretedOption_name_FIELD.full_name = "google.protobuf.UninterpretedOption_name"
    UninterpretedOption_name_FIELD.number = 2
    UninterpretedOption_name_FIELD.index = 0
    UninterpretedOption_name_FIELD.label = 3
    UninterpretedOption_name_FIELD.has_default_value = false
    UninterpretedOption_name_FIELD.default_value = {}
    UninterpretedOption_name_FIELD.message_type = UninterpretedOption.NamePart.GetDescriptor()
    UninterpretedOption_name_FIELD.type = 11
    UninterpretedOption_name_FIELD.cpp_type = 10
    UninterpretedOption_identifier_value_FIELD.name = "identifier_value"
    UninterpretedOption_identifier_value_FIELD.full_name = "google.protobuf.UninterpretedOption_identifier_value"
    UninterpretedOption_identifier_value_FIELD.number = 3
    UninterpretedOption_identifier_value_FIELD.index = 1
    UninterpretedOption_identifier_value_FIELD.label = 1
    UninterpretedOption_identifier_value_FIELD.has_default_value = false
    UninterpretedOption_identifier_value_FIELD.default_value = ""
    UninterpretedOption_identifier_value_FIELD.type = 9
    UninterpretedOption_identifier_value_FIELD.cpp_type = 9
    UninterpretedOption_positive_int_value_FIELD.name = "positive_int_value"
    UninterpretedOption_positive_int_value_FIELD.full_name = "google.protobuf.UninterpretedOption_positive_int_value"
    UninterpretedOption_positive_int_value_FIELD.number = 4
    UninterpretedOption_positive_int_value_FIELD.index = 2
    UninterpretedOption_positive_int_value_FIELD.label = 1
    UninterpretedOption_positive_int_value_FIELD.has_default_value = false
    UninterpretedOption_positive_int_value_FIELD.default_value = pb.number_to_int64(0)
    UninterpretedOption_positive_int_value_FIELD.type = 4
    UninterpretedOption_positive_int_value_FIELD.cpp_type = 4
    UninterpretedOption_negative_int_value_FIELD.name = "negative_int_value"
    UninterpretedOption_negative_int_value_FIELD.full_name = "google.protobuf.UninterpretedOption_negative_int_value"
    UninterpretedOption_negative_int_value_FIELD.number = 5
    UninterpretedOption_negative_int_value_FIELD.index = 3
    UninterpretedOption_negative_int_value_FIELD.label = 1
    UninterpretedOption_negative_int_value_FIELD.has_default_value = false
    UninterpretedOption_negative_int_value_FIELD.default_value = pb.number_to_int64(0)
    UninterpretedOption_negative_int_value_FIELD.type = 3
    UninterpretedOption_negative_int_value_FIELD.cpp_type = 2
    UninterpretedOption_double_value_FIELD.name = "double_value"
    UninterpretedOption_double_value_FIELD.full_name = "google.protobuf.UninterpretedOption_double_value"
    UninterpretedOption_double_value_FIELD.number = 6
    UninterpretedOption_double_value_FIELD.index = 4
    UninterpretedOption_double_value_FIELD.label = 1
    UninterpretedOption_double_value_FIELD.has_default_value = false
    UninterpretedOption_double_value_FIELD.default_value = 0
    UninterpretedOption_double_value_FIELD.type = 1
    UninterpretedOption_double_value_FIELD.cpp_type = 5
    UninterpretedOption_string_value_FIELD.name = "string_value"
    UninterpretedOption_string_value_FIELD.full_name = "google.protobuf.UninterpretedOption_string_value"
    UninterpretedOption_string_value_FIELD.number = 7
    UninterpretedOption_string_value_FIELD.index = 5
    UninterpretedOption_string_value_FIELD.label = 1
    UninterpretedOption_string_value_FIELD.has_default_value = false
    UninterpretedOption_string_value_FIELD.default_value = ""
    UninterpretedOption_string_value_FIELD.type = 12
    UninterpretedOption_string_value_FIELD.cpp_type = 9
    UninterpretedOption_aggregate_value_FIELD.name = "aggregate_value"
    UninterpretedOption_aggregate_value_FIELD.full_name = "google.protobuf.UninterpretedOption_aggregate_value"
    UninterpretedOption_aggregate_value_FIELD.number = 8
    UninterpretedOption_aggregate_value_FIELD.index = 6
    UninterpretedOption_aggregate_value_FIELD.label = 1
    UninterpretedOption_aggregate_value_FIELD.has_default_value = false
    UninterpretedOption_aggregate_value_FIELD.default_value = ""
    UninterpretedOption_aggregate_value_FIELD.type = 9
    UninterpretedOption_aggregate_value_FIELD.cpp_type = 9
    UninterpretedOption.name = "UninterpretedOption"
    UninterpretedOption.full_name = "google.protobuf.UninterpretedOption"
    UninterpretedOption.nested_types = {
      UninterpretedOption.NamePart
    }
    UninterpretedOption.enum_types = {}
    UninterpretedOption.fields = {
      UninterpretedOption_name_FIELD,
      UninterpretedOption_identifier_value_FIELD,
      UninterpretedOption_positive_int_value_FIELD,
      UninterpretedOption_negative_int_value_FIELD,
      UninterpretedOption_double_value_FIELD,
      UninterpretedOption_string_value_FIELD,
      UninterpretedOption_aggregate_value_FIELD
    }
    UninterpretedOption.is_extendable = false
    UninterpretedOption.extensions = {}
    _M.UninterpretedOption = protobuf.Message(UninterpretedOption)
  end
  _M.UninterpretedOption.NamePart = protobuf.Message(UninterpretedOption.NamePart)
end
do
  local SourceCodeInfo = protobuf.Descriptor()
  SourceCodeInfo.Location = protobuf.Descriptor()
  SourceCodeInfo.Location_path_FIELD = protobuf.FieldDescriptor()
  SourceCodeInfo.Location_span_FIELD = protobuf.FieldDescriptor()
  SourceCodeInfo.Location_leading_comments_FIELD = protobuf.FieldDescriptor()
  SourceCodeInfo.Location_trailing_comments_FIELD = protobuf.FieldDescriptor()
  do
    local SourceCodeInfo_location_FIELD = protobuf.FieldDescriptor()
    SourceCodeInfo.Location_path_FIELD.name = "path"
    SourceCodeInfo.Location_path_FIELD.full_name = "google.protobuf.SourceCodeInfo.Location_path"
    SourceCodeInfo.Location_path_FIELD.number = 1
    SourceCodeInfo.Location_path_FIELD.index = 0
    SourceCodeInfo.Location_path_FIELD.label = 3
    SourceCodeInfo.Location_path_FIELD.has_default_value = false
    SourceCodeInfo.Location_path_FIELD.default_value = {}
    SourceCodeInfo.Location_path_FIELD.type = 5
    SourceCodeInfo.Location_path_FIELD.cpp_type = 1
    SourceCodeInfo.Location_span_FIELD.name = "span"
    SourceCodeInfo.Location_span_FIELD.full_name = "google.protobuf.SourceCodeInfo.Location_span"
    SourceCodeInfo.Location_span_FIELD.number = 2
    SourceCodeInfo.Location_span_FIELD.index = 1
    SourceCodeInfo.Location_span_FIELD.label = 3
    SourceCodeInfo.Location_span_FIELD.has_default_value = false
    SourceCodeInfo.Location_span_FIELD.default_value = {}
    SourceCodeInfo.Location_span_FIELD.type = 5
    SourceCodeInfo.Location_span_FIELD.cpp_type = 1
    SourceCodeInfo.Location_leading_comments_FIELD.name = "leading_comments"
    SourceCodeInfo.Location_leading_comments_FIELD.full_name = "google.protobuf.SourceCodeInfo.Location_leading_comments"
    SourceCodeInfo.Location_leading_comments_FIELD.number = 3
    SourceCodeInfo.Location_leading_comments_FIELD.index = 2
    SourceCodeInfo.Location_leading_comments_FIELD.label = 1
    SourceCodeInfo.Location_leading_comments_FIELD.has_default_value = false
    SourceCodeInfo.Location_leading_comments_FIELD.default_value = ""
    SourceCodeInfo.Location_leading_comments_FIELD.type = 9
    SourceCodeInfo.Location_leading_comments_FIELD.cpp_type = 9
    SourceCodeInfo.Location_trailing_comments_FIELD.name = "trailing_comments"
    SourceCodeInfo.Location_trailing_comments_FIELD.full_name = "google.protobuf.SourceCodeInfo.Location_trailing_comments"
    SourceCodeInfo.Location_trailing_comments_FIELD.number = 4
    SourceCodeInfo.Location_trailing_comments_FIELD.index = 3
    SourceCodeInfo.Location_trailing_comments_FIELD.label = 1
    SourceCodeInfo.Location_trailing_comments_FIELD.has_default_value = false
    SourceCodeInfo.Location_trailing_comments_FIELD.default_value = ""
    SourceCodeInfo.Location_trailing_comments_FIELD.type = 9
    SourceCodeInfo.Location_trailing_comments_FIELD.cpp_type = 9
    SourceCodeInfo.Location.name = "Location"
    SourceCodeInfo.Location.full_name = "google.protobuf.SourceCodeInfo.Location"
    SourceCodeInfo.Location.nested_types = {}
    SourceCodeInfo.Location.enum_types = {}
    SourceCodeInfo.Location.fields = {
      SourceCodeInfo.Location_path_FIELD,
      SourceCodeInfo.Location_span_FIELD,
      SourceCodeInfo.Location_leading_comments_FIELD,
      SourceCodeInfo.Location_trailing_comments_FIELD
    }
    SourceCodeInfo.Location.is_extendable = false
    SourceCodeInfo.Location.extensions = {}
    SourceCodeInfo.Location.containing_type = SourceCodeInfo
    SourceCodeInfo_location_FIELD.name = "location"
    SourceCodeInfo_location_FIELD.full_name = "google.protobuf.SourceCodeInfo_location"
    SourceCodeInfo_location_FIELD.number = 1
    SourceCodeInfo_location_FIELD.index = 0
    SourceCodeInfo_location_FIELD.label = 3
    SourceCodeInfo_location_FIELD.has_default_value = false
    SourceCodeInfo_location_FIELD.default_value = {}
    SourceCodeInfo_location_FIELD.message_type = SourceCodeInfo.Location.GetDescriptor()
    SourceCodeInfo_location_FIELD.type = 11
    SourceCodeInfo_location_FIELD.cpp_type = 10
    SourceCodeInfo.name = "SourceCodeInfo"
    SourceCodeInfo.full_name = "google.protobuf.SourceCodeInfo"
    SourceCodeInfo.nested_types = {
      SourceCodeInfo.Location
    }
    SourceCodeInfo.enum_types = {}
    SourceCodeInfo.fields = {SourceCodeInfo_location_FIELD}
    SourceCodeInfo.is_extendable = false
    SourceCodeInfo.extensions = {}
    _M.SourceCodeInfo = protobuf.Message(SourceCodeInfo)
  end
  _M.SourceCodeInfo.Location = protobuf.Message(SourceCodeInfo.Location)
end
return _M
