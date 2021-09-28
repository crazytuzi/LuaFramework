
local protobuf = require "protobuf"
module('shopMallHandler_pb')


MALLITEM = protobuf.Descriptor();
local MALLITEM_ID_FIELD = protobuf.FieldDescriptor();
local MALLITEM_CODE_FIELD = protobuf.FieldDescriptor();
local MALLITEM_GROUPCOUNT_FIELD = protobuf.FieldDescriptor();
local MALLITEM_ORIGINPRICE_FIELD = protobuf.FieldDescriptor();
local MALLITEM_NOWPRICE_FIELD = protobuf.FieldDescriptor();
local MALLITEM_DISCOUNT_FIELD = protobuf.FieldDescriptor();
local MALLITEM_ENDTIME_FIELD = protobuf.FieldDescriptor();
local MALLITEM_REMAINNUM_FIELD = protobuf.FieldDescriptor();
local MALLITEM_CONSUMESCORE_FIELD = protobuf.FieldDescriptor();
local MALLITEM_BINDTYPE_FIELD = protobuf.FieldDescriptor();
local MALLITEM_CANSEND_FIELD = protobuf.FieldDescriptor();
MALLSCOREITEM = protobuf.Descriptor();
local MALLSCOREITEM_ID_FIELD = protobuf.FieldDescriptor();
local MALLSCOREITEM_CODE_FIELD = protobuf.FieldDescriptor();
local MALLSCOREITEM_GROUPCOUNT_FIELD = protobuf.FieldDescriptor();
local MALLSCOREITEM_CONSUMESCORE_FIELD = protobuf.FieldDescriptor();
local MALLSCOREITEM_ISSELLOUT_FIELD = protobuf.FieldDescriptor();
local MALLSCOREITEM_BINDTYPE_FIELD = protobuf.FieldDescriptor();
GETMALLITEMLISTREQUEST = protobuf.Descriptor();
local GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD = protobuf.FieldDescriptor();
local GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD = protobuf.FieldDescriptor();
GETMALLITEMLISTRESPONSE = protobuf.Descriptor();
local GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD = protobuf.FieldDescriptor();
local GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD = protobuf.FieldDescriptor();
BUYMALLITEMREQUEST = protobuf.Descriptor();
local BUYMALLITEMREQUEST_C2S_ITEMID_FIELD = protobuf.FieldDescriptor();
local BUYMALLITEMREQUEST_C2S_COUNT_FIELD = protobuf.FieldDescriptor();
local BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD = protobuf.FieldDescriptor();
local BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD = protobuf.FieldDescriptor();
BUYMALLITEMRESPONSE = protobuf.Descriptor();
local BUYMALLITEMRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local BUYMALLITEMRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD = protobuf.FieldDescriptor();
GETMALLSCOREITEMLISTREQUEST = protobuf.Descriptor();
GETMALLSCOREITEMLISTRESPONSE = protobuf.Descriptor();
local GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD = protobuf.FieldDescriptor();
BUYMALLSCOREITEMREQUEST = protobuf.Descriptor();
local BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD = protobuf.FieldDescriptor();
BUYMALLSCOREITEMRESPONSE = protobuf.Descriptor();
local BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
MALLTAB = protobuf.Descriptor();
local MALLTAB_MONEYTYPE_FIELD = protobuf.FieldDescriptor();
local MALLTAB_ITEMTYPE_FIELD = protobuf.FieldDescriptor();
local MALLTAB_ISOPEN_FIELD = protobuf.FieldDescriptor();
local MALLTAB_NAME_FIELD = protobuf.FieldDescriptor();
local MALLTAB_SCRIPTNUM_FIELD = protobuf.FieldDescriptor();
local MALLTAB_ISLIMIT_FIELD = protobuf.FieldDescriptor();
local MALLTAB_LASTNUMTEXT_FIELD = protobuf.FieldDescriptor();
GETMALLTABSREQUEST = protobuf.Descriptor();
GETMALLTABSRESPONSE = protobuf.Descriptor();
local GETMALLTABSRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local GETMALLTABSRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local GETMALLTABSRESPONSE_S2C_TABS_FIELD = protobuf.FieldDescriptor();

MALLITEM_ID_FIELD.name = "id"
MALLITEM_ID_FIELD.full_name = ".pomelo.area.MallItem.id"
MALLITEM_ID_FIELD.number = 1
MALLITEM_ID_FIELD.index = 0
MALLITEM_ID_FIELD.label = 2
MALLITEM_ID_FIELD.has_default_value = false
MALLITEM_ID_FIELD.default_value = ""
MALLITEM_ID_FIELD.type = 9
MALLITEM_ID_FIELD.cpp_type = 9

MALLITEM_CODE_FIELD.name = "code"
MALLITEM_CODE_FIELD.full_name = ".pomelo.area.MallItem.code"
MALLITEM_CODE_FIELD.number = 2
MALLITEM_CODE_FIELD.index = 1
MALLITEM_CODE_FIELD.label = 2
MALLITEM_CODE_FIELD.has_default_value = false
MALLITEM_CODE_FIELD.default_value = ""
MALLITEM_CODE_FIELD.type = 9
MALLITEM_CODE_FIELD.cpp_type = 9

MALLITEM_GROUPCOUNT_FIELD.name = "groupCount"
MALLITEM_GROUPCOUNT_FIELD.full_name = ".pomelo.area.MallItem.groupCount"
MALLITEM_GROUPCOUNT_FIELD.number = 3
MALLITEM_GROUPCOUNT_FIELD.index = 2
MALLITEM_GROUPCOUNT_FIELD.label = 2
MALLITEM_GROUPCOUNT_FIELD.has_default_value = false
MALLITEM_GROUPCOUNT_FIELD.default_value = 0
MALLITEM_GROUPCOUNT_FIELD.type = 5
MALLITEM_GROUPCOUNT_FIELD.cpp_type = 1

MALLITEM_ORIGINPRICE_FIELD.name = "originPrice"
MALLITEM_ORIGINPRICE_FIELD.full_name = ".pomelo.area.MallItem.originPrice"
MALLITEM_ORIGINPRICE_FIELD.number = 4
MALLITEM_ORIGINPRICE_FIELD.index = 3
MALLITEM_ORIGINPRICE_FIELD.label = 2
MALLITEM_ORIGINPRICE_FIELD.has_default_value = false
MALLITEM_ORIGINPRICE_FIELD.default_value = 0
MALLITEM_ORIGINPRICE_FIELD.type = 5
MALLITEM_ORIGINPRICE_FIELD.cpp_type = 1

MALLITEM_NOWPRICE_FIELD.name = "nowPrice"
MALLITEM_NOWPRICE_FIELD.full_name = ".pomelo.area.MallItem.nowPrice"
MALLITEM_NOWPRICE_FIELD.number = 5
MALLITEM_NOWPRICE_FIELD.index = 4
MALLITEM_NOWPRICE_FIELD.label = 2
MALLITEM_NOWPRICE_FIELD.has_default_value = false
MALLITEM_NOWPRICE_FIELD.default_value = 0
MALLITEM_NOWPRICE_FIELD.type = 5
MALLITEM_NOWPRICE_FIELD.cpp_type = 1

MALLITEM_DISCOUNT_FIELD.name = "disCount"
MALLITEM_DISCOUNT_FIELD.full_name = ".pomelo.area.MallItem.disCount"
MALLITEM_DISCOUNT_FIELD.number = 6
MALLITEM_DISCOUNT_FIELD.index = 5
MALLITEM_DISCOUNT_FIELD.label = 2
MALLITEM_DISCOUNT_FIELD.has_default_value = false
MALLITEM_DISCOUNT_FIELD.default_value = 0
MALLITEM_DISCOUNT_FIELD.type = 5
MALLITEM_DISCOUNT_FIELD.cpp_type = 1

MALLITEM_ENDTIME_FIELD.name = "endTime"
MALLITEM_ENDTIME_FIELD.full_name = ".pomelo.area.MallItem.endTime"
MALLITEM_ENDTIME_FIELD.number = 7
MALLITEM_ENDTIME_FIELD.index = 6
MALLITEM_ENDTIME_FIELD.label = 2
MALLITEM_ENDTIME_FIELD.has_default_value = false
MALLITEM_ENDTIME_FIELD.default_value = 0
MALLITEM_ENDTIME_FIELD.type = 5
MALLITEM_ENDTIME_FIELD.cpp_type = 1

MALLITEM_REMAINNUM_FIELD.name = "remainNum"
MALLITEM_REMAINNUM_FIELD.full_name = ".pomelo.area.MallItem.remainNum"
MALLITEM_REMAINNUM_FIELD.number = 8
MALLITEM_REMAINNUM_FIELD.index = 7
MALLITEM_REMAINNUM_FIELD.label = 2
MALLITEM_REMAINNUM_FIELD.has_default_value = false
MALLITEM_REMAINNUM_FIELD.default_value = 0
MALLITEM_REMAINNUM_FIELD.type = 5
MALLITEM_REMAINNUM_FIELD.cpp_type = 1

MALLITEM_CONSUMESCORE_FIELD.name = "consumeScore"
MALLITEM_CONSUMESCORE_FIELD.full_name = ".pomelo.area.MallItem.consumeScore"
MALLITEM_CONSUMESCORE_FIELD.number = 9
MALLITEM_CONSUMESCORE_FIELD.index = 8
MALLITEM_CONSUMESCORE_FIELD.label = 2
MALLITEM_CONSUMESCORE_FIELD.has_default_value = false
MALLITEM_CONSUMESCORE_FIELD.default_value = 0
MALLITEM_CONSUMESCORE_FIELD.type = 5
MALLITEM_CONSUMESCORE_FIELD.cpp_type = 1

MALLITEM_BINDTYPE_FIELD.name = "bindType"
MALLITEM_BINDTYPE_FIELD.full_name = ".pomelo.area.MallItem.bindType"
MALLITEM_BINDTYPE_FIELD.number = 10
MALLITEM_BINDTYPE_FIELD.index = 9
MALLITEM_BINDTYPE_FIELD.label = 2
MALLITEM_BINDTYPE_FIELD.has_default_value = false
MALLITEM_BINDTYPE_FIELD.default_value = 0
MALLITEM_BINDTYPE_FIELD.type = 5
MALLITEM_BINDTYPE_FIELD.cpp_type = 1

MALLITEM_CANSEND_FIELD.name = "canSend"
MALLITEM_CANSEND_FIELD.full_name = ".pomelo.area.MallItem.canSend"
MALLITEM_CANSEND_FIELD.number = 11
MALLITEM_CANSEND_FIELD.index = 10
MALLITEM_CANSEND_FIELD.label = 2
MALLITEM_CANSEND_FIELD.has_default_value = false
MALLITEM_CANSEND_FIELD.default_value = 0
MALLITEM_CANSEND_FIELD.type = 5
MALLITEM_CANSEND_FIELD.cpp_type = 1

MALLITEM.name = "MallItem"
MALLITEM.full_name = ".pomelo.area.MallItem"
MALLITEM.nested_types = {}
MALLITEM.enum_types = {}
MALLITEM.fields = {MALLITEM_ID_FIELD, MALLITEM_CODE_FIELD, MALLITEM_GROUPCOUNT_FIELD, MALLITEM_ORIGINPRICE_FIELD, MALLITEM_NOWPRICE_FIELD, MALLITEM_DISCOUNT_FIELD, MALLITEM_ENDTIME_FIELD, MALLITEM_REMAINNUM_FIELD, MALLITEM_CONSUMESCORE_FIELD, MALLITEM_BINDTYPE_FIELD, MALLITEM_CANSEND_FIELD}
MALLITEM.is_extendable = false
MALLITEM.extensions = {}
MALLSCOREITEM_ID_FIELD.name = "id"
MALLSCOREITEM_ID_FIELD.full_name = ".pomelo.area.MallScoreItem.id"
MALLSCOREITEM_ID_FIELD.number = 1
MALLSCOREITEM_ID_FIELD.index = 0
MALLSCOREITEM_ID_FIELD.label = 2
MALLSCOREITEM_ID_FIELD.has_default_value = false
MALLSCOREITEM_ID_FIELD.default_value = ""
MALLSCOREITEM_ID_FIELD.type = 9
MALLSCOREITEM_ID_FIELD.cpp_type = 9

MALLSCOREITEM_CODE_FIELD.name = "code"
MALLSCOREITEM_CODE_FIELD.full_name = ".pomelo.area.MallScoreItem.code"
MALLSCOREITEM_CODE_FIELD.number = 2
MALLSCOREITEM_CODE_FIELD.index = 1
MALLSCOREITEM_CODE_FIELD.label = 2
MALLSCOREITEM_CODE_FIELD.has_default_value = false
MALLSCOREITEM_CODE_FIELD.default_value = ""
MALLSCOREITEM_CODE_FIELD.type = 9
MALLSCOREITEM_CODE_FIELD.cpp_type = 9

MALLSCOREITEM_GROUPCOUNT_FIELD.name = "groupCount"
MALLSCOREITEM_GROUPCOUNT_FIELD.full_name = ".pomelo.area.MallScoreItem.groupCount"
MALLSCOREITEM_GROUPCOUNT_FIELD.number = 3
MALLSCOREITEM_GROUPCOUNT_FIELD.index = 2
MALLSCOREITEM_GROUPCOUNT_FIELD.label = 2
MALLSCOREITEM_GROUPCOUNT_FIELD.has_default_value = false
MALLSCOREITEM_GROUPCOUNT_FIELD.default_value = 0
MALLSCOREITEM_GROUPCOUNT_FIELD.type = 5
MALLSCOREITEM_GROUPCOUNT_FIELD.cpp_type = 1

MALLSCOREITEM_CONSUMESCORE_FIELD.name = "consumeScore"
MALLSCOREITEM_CONSUMESCORE_FIELD.full_name = ".pomelo.area.MallScoreItem.consumeScore"
MALLSCOREITEM_CONSUMESCORE_FIELD.number = 4
MALLSCOREITEM_CONSUMESCORE_FIELD.index = 3
MALLSCOREITEM_CONSUMESCORE_FIELD.label = 2
MALLSCOREITEM_CONSUMESCORE_FIELD.has_default_value = false
MALLSCOREITEM_CONSUMESCORE_FIELD.default_value = 0
MALLSCOREITEM_CONSUMESCORE_FIELD.type = 5
MALLSCOREITEM_CONSUMESCORE_FIELD.cpp_type = 1

MALLSCOREITEM_ISSELLOUT_FIELD.name = "isSellOut"
MALLSCOREITEM_ISSELLOUT_FIELD.full_name = ".pomelo.area.MallScoreItem.isSellOut"
MALLSCOREITEM_ISSELLOUT_FIELD.number = 5
MALLSCOREITEM_ISSELLOUT_FIELD.index = 4
MALLSCOREITEM_ISSELLOUT_FIELD.label = 2
MALLSCOREITEM_ISSELLOUT_FIELD.has_default_value = false
MALLSCOREITEM_ISSELLOUT_FIELD.default_value = 0
MALLSCOREITEM_ISSELLOUT_FIELD.type = 5
MALLSCOREITEM_ISSELLOUT_FIELD.cpp_type = 1

MALLSCOREITEM_BINDTYPE_FIELD.name = "bindType"
MALLSCOREITEM_BINDTYPE_FIELD.full_name = ".pomelo.area.MallScoreItem.bindType"
MALLSCOREITEM_BINDTYPE_FIELD.number = 6
MALLSCOREITEM_BINDTYPE_FIELD.index = 5
MALLSCOREITEM_BINDTYPE_FIELD.label = 2
MALLSCOREITEM_BINDTYPE_FIELD.has_default_value = false
MALLSCOREITEM_BINDTYPE_FIELD.default_value = 0
MALLSCOREITEM_BINDTYPE_FIELD.type = 5
MALLSCOREITEM_BINDTYPE_FIELD.cpp_type = 1

MALLSCOREITEM.name = "MallScoreItem"
MALLSCOREITEM.full_name = ".pomelo.area.MallScoreItem"
MALLSCOREITEM.nested_types = {}
MALLSCOREITEM.enum_types = {}
MALLSCOREITEM.fields = {MALLSCOREITEM_ID_FIELD, MALLSCOREITEM_CODE_FIELD, MALLSCOREITEM_GROUPCOUNT_FIELD, MALLSCOREITEM_CONSUMESCORE_FIELD, MALLSCOREITEM_ISSELLOUT_FIELD, MALLSCOREITEM_BINDTYPE_FIELD}
MALLSCOREITEM.is_extendable = false
MALLSCOREITEM.extensions = {}
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.name = "c2s_moneyType"
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.full_name = ".pomelo.area.GetMallItemListRequest.c2s_moneyType"
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.number = 1
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.index = 0
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.label = 1
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.has_default_value = false
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.default_value = 0
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.type = 5
GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD.cpp_type = 1

GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.name = "c2s_itemType"
GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.full_name = ".pomelo.area.GetMallItemListRequest.c2s_itemType"
GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.number = 2
GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.index = 1
GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.label = 2
GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.has_default_value = false
GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.default_value = 0
GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.type = 5
GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD.cpp_type = 1

GETMALLITEMLISTREQUEST.name = "GetMallItemListRequest"
GETMALLITEMLISTREQUEST.full_name = ".pomelo.area.GetMallItemListRequest"
GETMALLITEMLISTREQUEST.nested_types = {}
GETMALLITEMLISTREQUEST.enum_types = {}
GETMALLITEMLISTREQUEST.fields = {GETMALLITEMLISTREQUEST_C2S_MONEYTYPE_FIELD, GETMALLITEMLISTREQUEST_C2S_ITEMTYPE_FIELD}
GETMALLITEMLISTREQUEST.is_extendable = false
GETMALLITEMLISTREQUEST.extensions = {}
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.GetMallItemListResponse.s2c_code"
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.number = 1
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.index = 0
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.label = 2
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.has_default_value = false
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.default_value = 0
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.type = 5
GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD.cpp_type = 1

GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.GetMallItemListResponse.s2c_msg"
GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.number = 2
GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.index = 1
GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.label = 1
GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.has_default_value = false
GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.default_value = ""
GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.type = 9
GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD.cpp_type = 9

GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.name = "s2c_endTime"
GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.full_name = ".pomelo.area.GetMallItemListResponse.s2c_endTime"
GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.number = 3
GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.index = 2
GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.label = 1
GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.has_default_value = false
GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.default_value = 0
GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.type = 5
GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD.cpp_type = 1

GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.name = "s2c_items"
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.full_name = ".pomelo.area.GetMallItemListResponse.s2c_items"
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.number = 4
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.index = 3
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.label = 3
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.has_default_value = false
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.default_value = {}
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.message_type = MALLITEM
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.type = 11
GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD.cpp_type = 10

GETMALLITEMLISTRESPONSE.name = "GetMallItemListResponse"
GETMALLITEMLISTRESPONSE.full_name = ".pomelo.area.GetMallItemListResponse"
GETMALLITEMLISTRESPONSE.nested_types = {}
GETMALLITEMLISTRESPONSE.enum_types = {}
GETMALLITEMLISTRESPONSE.fields = {GETMALLITEMLISTRESPONSE_S2C_CODE_FIELD, GETMALLITEMLISTRESPONSE_S2C_MSG_FIELD, GETMALLITEMLISTRESPONSE_S2C_ENDTIME_FIELD, GETMALLITEMLISTRESPONSE_S2C_ITEMS_FIELD}
GETMALLITEMLISTRESPONSE.is_extendable = false
GETMALLITEMLISTRESPONSE.extensions = {}
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.name = "c2s_itemId"
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.full_name = ".pomelo.area.BuyMallItemRequest.c2s_itemId"
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.number = 1
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.index = 0
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.label = 2
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.has_default_value = false
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.default_value = ""
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.type = 9
BUYMALLITEMREQUEST_C2S_ITEMID_FIELD.cpp_type = 9

BUYMALLITEMREQUEST_C2S_COUNT_FIELD.name = "c2s_count"
BUYMALLITEMREQUEST_C2S_COUNT_FIELD.full_name = ".pomelo.area.BuyMallItemRequest.c2s_count"
BUYMALLITEMREQUEST_C2S_COUNT_FIELD.number = 2
BUYMALLITEMREQUEST_C2S_COUNT_FIELD.index = 1
BUYMALLITEMREQUEST_C2S_COUNT_FIELD.label = 2
BUYMALLITEMREQUEST_C2S_COUNT_FIELD.has_default_value = false
BUYMALLITEMREQUEST_C2S_COUNT_FIELD.default_value = 0
BUYMALLITEMREQUEST_C2S_COUNT_FIELD.type = 5
BUYMALLITEMREQUEST_C2S_COUNT_FIELD.cpp_type = 1

BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.name = "c2s_playerId"
BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.full_name = ".pomelo.area.BuyMallItemRequest.c2s_playerId"
BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.number = 3
BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.index = 2
BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.label = 2
BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.has_default_value = false
BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.default_value = ""
BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.type = 9
BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD.cpp_type = 9

BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.name = "c2s_bDiamond"
BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.full_name = ".pomelo.area.BuyMallItemRequest.c2s_bDiamond"
BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.number = 4
BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.index = 3
BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.label = 2
BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.has_default_value = false
BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.default_value = 0
BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.type = 5
BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD.cpp_type = 1

BUYMALLITEMREQUEST.name = "BuyMallItemRequest"
BUYMALLITEMREQUEST.full_name = ".pomelo.area.BuyMallItemRequest"
BUYMALLITEMREQUEST.nested_types = {}
BUYMALLITEMREQUEST.enum_types = {}
BUYMALLITEMREQUEST.fields = {BUYMALLITEMREQUEST_C2S_ITEMID_FIELD, BUYMALLITEMREQUEST_C2S_COUNT_FIELD, BUYMALLITEMREQUEST_C2S_PLAYERID_FIELD, BUYMALLITEMREQUEST_C2S_BDIAMOND_FIELD}
BUYMALLITEMREQUEST.is_extendable = false
BUYMALLITEMREQUEST.extensions = {}
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.BuyMallItemResponse.s2c_code"
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.number = 1
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.index = 0
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.label = 2
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.has_default_value = false
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.default_value = 0
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.type = 5
BUYMALLITEMRESPONSE_S2C_CODE_FIELD.cpp_type = 1

BUYMALLITEMRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
BUYMALLITEMRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.BuyMallItemResponse.s2c_msg"
BUYMALLITEMRESPONSE_S2C_MSG_FIELD.number = 2
BUYMALLITEMRESPONSE_S2C_MSG_FIELD.index = 1
BUYMALLITEMRESPONSE_S2C_MSG_FIELD.label = 1
BUYMALLITEMRESPONSE_S2C_MSG_FIELD.has_default_value = false
BUYMALLITEMRESPONSE_S2C_MSG_FIELD.default_value = ""
BUYMALLITEMRESPONSE_S2C_MSG_FIELD.type = 9
BUYMALLITEMRESPONSE_S2C_MSG_FIELD.cpp_type = 9

BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.name = "total_num"
BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.full_name = ".pomelo.area.BuyMallItemResponse.total_num"
BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.number = 3
BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.index = 2
BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.label = 1
BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.has_default_value = false
BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.default_value = 0
BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.type = 5
BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD.cpp_type = 1

BUYMALLITEMRESPONSE.name = "BuyMallItemResponse"
BUYMALLITEMRESPONSE.full_name = ".pomelo.area.BuyMallItemResponse"
BUYMALLITEMRESPONSE.nested_types = {}
BUYMALLITEMRESPONSE.enum_types = {}
BUYMALLITEMRESPONSE.fields = {BUYMALLITEMRESPONSE_S2C_CODE_FIELD, BUYMALLITEMRESPONSE_S2C_MSG_FIELD, BUYMALLITEMRESPONSE_TOTAL_NUM_FIELD}
BUYMALLITEMRESPONSE.is_extendable = false
BUYMALLITEMRESPONSE.extensions = {}
GETMALLSCOREITEMLISTREQUEST.name = "GetMallScoreItemListRequest"
GETMALLSCOREITEMLISTREQUEST.full_name = ".pomelo.area.GetMallScoreItemListRequest"
GETMALLSCOREITEMLISTREQUEST.nested_types = {}
GETMALLSCOREITEMLISTREQUEST.enum_types = {}
GETMALLSCOREITEMLISTREQUEST.fields = {}
GETMALLSCOREITEMLISTREQUEST.is_extendable = false
GETMALLSCOREITEMLISTREQUEST.extensions = {}
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.GetMallScoreItemListResponse.s2c_code"
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.number = 1
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.index = 0
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.label = 2
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.has_default_value = false
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.default_value = 0
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.type = 5
GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD.cpp_type = 1

GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.GetMallScoreItemListResponse.s2c_msg"
GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.number = 2
GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.index = 1
GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.label = 1
GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.has_default_value = false
GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.default_value = ""
GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.type = 9
GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD.cpp_type = 9

GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.name = "s2c_items"
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.full_name = ".pomelo.area.GetMallScoreItemListResponse.s2c_items"
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.number = 3
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.index = 2
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.label = 3
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.has_default_value = false
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.default_value = {}
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.message_type = MALLSCOREITEM
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.type = 11
GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD.cpp_type = 10

GETMALLSCOREITEMLISTRESPONSE.name = "GetMallScoreItemListResponse"
GETMALLSCOREITEMLISTRESPONSE.full_name = ".pomelo.area.GetMallScoreItemListResponse"
GETMALLSCOREITEMLISTRESPONSE.nested_types = {}
GETMALLSCOREITEMLISTRESPONSE.enum_types = {}
GETMALLSCOREITEMLISTRESPONSE.fields = {GETMALLSCOREITEMLISTRESPONSE_S2C_CODE_FIELD, GETMALLSCOREITEMLISTRESPONSE_S2C_MSG_FIELD, GETMALLSCOREITEMLISTRESPONSE_S2C_ITEMS_FIELD}
GETMALLSCOREITEMLISTRESPONSE.is_extendable = false
GETMALLSCOREITEMLISTRESPONSE.extensions = {}
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.name = "c2s_itemId"
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.full_name = ".pomelo.area.BuyMallScoreItemRequest.c2s_itemId"
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.number = 1
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.index = 0
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.label = 2
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.has_default_value = false
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.default_value = ""
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.type = 9
BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD.cpp_type = 9

BUYMALLSCOREITEMREQUEST.name = "BuyMallScoreItemRequest"
BUYMALLSCOREITEMREQUEST.full_name = ".pomelo.area.BuyMallScoreItemRequest"
BUYMALLSCOREITEMREQUEST.nested_types = {}
BUYMALLSCOREITEMREQUEST.enum_types = {}
BUYMALLSCOREITEMREQUEST.fields = {BUYMALLSCOREITEMREQUEST_C2S_ITEMID_FIELD}
BUYMALLSCOREITEMREQUEST.is_extendable = false
BUYMALLSCOREITEMREQUEST.extensions = {}
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.BuyMallScoreItemResponse.s2c_code"
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.number = 1
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.index = 0
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.label = 2
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.has_default_value = false
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.default_value = 0
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.type = 5
BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD.cpp_type = 1

BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.BuyMallScoreItemResponse.s2c_msg"
BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.number = 2
BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.index = 1
BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.label = 1
BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.has_default_value = false
BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.default_value = ""
BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.type = 9
BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD.cpp_type = 9

BUYMALLSCOREITEMRESPONSE.name = "BuyMallScoreItemResponse"
BUYMALLSCOREITEMRESPONSE.full_name = ".pomelo.area.BuyMallScoreItemResponse"
BUYMALLSCOREITEMRESPONSE.nested_types = {}
BUYMALLSCOREITEMRESPONSE.enum_types = {}
BUYMALLSCOREITEMRESPONSE.fields = {BUYMALLSCOREITEMRESPONSE_S2C_CODE_FIELD, BUYMALLSCOREITEMRESPONSE_S2C_MSG_FIELD}
BUYMALLSCOREITEMRESPONSE.is_extendable = false
BUYMALLSCOREITEMRESPONSE.extensions = {}
MALLTAB_MONEYTYPE_FIELD.name = "moneyType"
MALLTAB_MONEYTYPE_FIELD.full_name = ".pomelo.area.MallTab.moneyType"
MALLTAB_MONEYTYPE_FIELD.number = 1
MALLTAB_MONEYTYPE_FIELD.index = 0
MALLTAB_MONEYTYPE_FIELD.label = 2
MALLTAB_MONEYTYPE_FIELD.has_default_value = false
MALLTAB_MONEYTYPE_FIELD.default_value = 0
MALLTAB_MONEYTYPE_FIELD.type = 5
MALLTAB_MONEYTYPE_FIELD.cpp_type = 1

MALLTAB_ITEMTYPE_FIELD.name = "itemType"
MALLTAB_ITEMTYPE_FIELD.full_name = ".pomelo.area.MallTab.itemType"
MALLTAB_ITEMTYPE_FIELD.number = 2
MALLTAB_ITEMTYPE_FIELD.index = 1
MALLTAB_ITEMTYPE_FIELD.label = 2
MALLTAB_ITEMTYPE_FIELD.has_default_value = false
MALLTAB_ITEMTYPE_FIELD.default_value = 0
MALLTAB_ITEMTYPE_FIELD.type = 5
MALLTAB_ITEMTYPE_FIELD.cpp_type = 1

MALLTAB_ISOPEN_FIELD.name = "isOpen"
MALLTAB_ISOPEN_FIELD.full_name = ".pomelo.area.MallTab.isOpen"
MALLTAB_ISOPEN_FIELD.number = 3
MALLTAB_ISOPEN_FIELD.index = 2
MALLTAB_ISOPEN_FIELD.label = 2
MALLTAB_ISOPEN_FIELD.has_default_value = false
MALLTAB_ISOPEN_FIELD.default_value = 0
MALLTAB_ISOPEN_FIELD.type = 5
MALLTAB_ISOPEN_FIELD.cpp_type = 1

MALLTAB_NAME_FIELD.name = "name"
MALLTAB_NAME_FIELD.full_name = ".pomelo.area.MallTab.name"
MALLTAB_NAME_FIELD.number = 4
MALLTAB_NAME_FIELD.index = 3
MALLTAB_NAME_FIELD.label = 2
MALLTAB_NAME_FIELD.has_default_value = false
MALLTAB_NAME_FIELD.default_value = ""
MALLTAB_NAME_FIELD.type = 9
MALLTAB_NAME_FIELD.cpp_type = 9

MALLTAB_SCRIPTNUM_FIELD.name = "scriptNum"
MALLTAB_SCRIPTNUM_FIELD.full_name = ".pomelo.area.MallTab.scriptNum"
MALLTAB_SCRIPTNUM_FIELD.number = 5
MALLTAB_SCRIPTNUM_FIELD.index = 4
MALLTAB_SCRIPTNUM_FIELD.label = 2
MALLTAB_SCRIPTNUM_FIELD.has_default_value = false
MALLTAB_SCRIPTNUM_FIELD.default_value = 0
MALLTAB_SCRIPTNUM_FIELD.type = 5
MALLTAB_SCRIPTNUM_FIELD.cpp_type = 1

MALLTAB_ISLIMIT_FIELD.name = "isLimit"
MALLTAB_ISLIMIT_FIELD.full_name = ".pomelo.area.MallTab.isLimit"
MALLTAB_ISLIMIT_FIELD.number = 6
MALLTAB_ISLIMIT_FIELD.index = 5
MALLTAB_ISLIMIT_FIELD.label = 2
MALLTAB_ISLIMIT_FIELD.has_default_value = false
MALLTAB_ISLIMIT_FIELD.default_value = 0
MALLTAB_ISLIMIT_FIELD.type = 5
MALLTAB_ISLIMIT_FIELD.cpp_type = 1

MALLTAB_LASTNUMTEXT_FIELD.name = "lastNumText"
MALLTAB_LASTNUMTEXT_FIELD.full_name = ".pomelo.area.MallTab.lastNumText"
MALLTAB_LASTNUMTEXT_FIELD.number = 7
MALLTAB_LASTNUMTEXT_FIELD.index = 6
MALLTAB_LASTNUMTEXT_FIELD.label = 1
MALLTAB_LASTNUMTEXT_FIELD.has_default_value = false
MALLTAB_LASTNUMTEXT_FIELD.default_value = ""
MALLTAB_LASTNUMTEXT_FIELD.type = 9
MALLTAB_LASTNUMTEXT_FIELD.cpp_type = 9

MALLTAB.name = "MallTab"
MALLTAB.full_name = ".pomelo.area.MallTab"
MALLTAB.nested_types = {}
MALLTAB.enum_types = {}
MALLTAB.fields = {MALLTAB_MONEYTYPE_FIELD, MALLTAB_ITEMTYPE_FIELD, MALLTAB_ISOPEN_FIELD, MALLTAB_NAME_FIELD, MALLTAB_SCRIPTNUM_FIELD, MALLTAB_ISLIMIT_FIELD, MALLTAB_LASTNUMTEXT_FIELD}
MALLTAB.is_extendable = false
MALLTAB.extensions = {}
GETMALLTABSREQUEST.name = "GetMallTabsRequest"
GETMALLTABSREQUEST.full_name = ".pomelo.area.GetMallTabsRequest"
GETMALLTABSREQUEST.nested_types = {}
GETMALLTABSREQUEST.enum_types = {}
GETMALLTABSREQUEST.fields = {}
GETMALLTABSREQUEST.is_extendable = false
GETMALLTABSREQUEST.extensions = {}
GETMALLTABSRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
GETMALLTABSRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.GetMallTabsResponse.s2c_code"
GETMALLTABSRESPONSE_S2C_CODE_FIELD.number = 1
GETMALLTABSRESPONSE_S2C_CODE_FIELD.index = 0
GETMALLTABSRESPONSE_S2C_CODE_FIELD.label = 2
GETMALLTABSRESPONSE_S2C_CODE_FIELD.has_default_value = false
GETMALLTABSRESPONSE_S2C_CODE_FIELD.default_value = 0
GETMALLTABSRESPONSE_S2C_CODE_FIELD.type = 5
GETMALLTABSRESPONSE_S2C_CODE_FIELD.cpp_type = 1

GETMALLTABSRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
GETMALLTABSRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.GetMallTabsResponse.s2c_msg"
GETMALLTABSRESPONSE_S2C_MSG_FIELD.number = 2
GETMALLTABSRESPONSE_S2C_MSG_FIELD.index = 1
GETMALLTABSRESPONSE_S2C_MSG_FIELD.label = 1
GETMALLTABSRESPONSE_S2C_MSG_FIELD.has_default_value = false
GETMALLTABSRESPONSE_S2C_MSG_FIELD.default_value = ""
GETMALLTABSRESPONSE_S2C_MSG_FIELD.type = 9
GETMALLTABSRESPONSE_S2C_MSG_FIELD.cpp_type = 9

GETMALLTABSRESPONSE_S2C_TABS_FIELD.name = "s2c_tabs"
GETMALLTABSRESPONSE_S2C_TABS_FIELD.full_name = ".pomelo.area.GetMallTabsResponse.s2c_tabs"
GETMALLTABSRESPONSE_S2C_TABS_FIELD.number = 3
GETMALLTABSRESPONSE_S2C_TABS_FIELD.index = 2
GETMALLTABSRESPONSE_S2C_TABS_FIELD.label = 3
GETMALLTABSRESPONSE_S2C_TABS_FIELD.has_default_value = false
GETMALLTABSRESPONSE_S2C_TABS_FIELD.default_value = {}
GETMALLTABSRESPONSE_S2C_TABS_FIELD.message_type = MALLTAB
GETMALLTABSRESPONSE_S2C_TABS_FIELD.type = 11
GETMALLTABSRESPONSE_S2C_TABS_FIELD.cpp_type = 10

GETMALLTABSRESPONSE.name = "GetMallTabsResponse"
GETMALLTABSRESPONSE.full_name = ".pomelo.area.GetMallTabsResponse"
GETMALLTABSRESPONSE.nested_types = {}
GETMALLTABSRESPONSE.enum_types = {}
GETMALLTABSRESPONSE.fields = {GETMALLTABSRESPONSE_S2C_CODE_FIELD, GETMALLTABSRESPONSE_S2C_MSG_FIELD, GETMALLTABSRESPONSE_S2C_TABS_FIELD}
GETMALLTABSRESPONSE.is_extendable = false
GETMALLTABSRESPONSE.extensions = {}

BuyMallItemRequest = protobuf.Message(BUYMALLITEMREQUEST)
BuyMallItemResponse = protobuf.Message(BUYMALLITEMRESPONSE)
BuyMallScoreItemRequest = protobuf.Message(BUYMALLSCOREITEMREQUEST)
BuyMallScoreItemResponse = protobuf.Message(BUYMALLSCOREITEMRESPONSE)
GetMallItemListRequest = protobuf.Message(GETMALLITEMLISTREQUEST)
GetMallItemListResponse = protobuf.Message(GETMALLITEMLISTRESPONSE)
GetMallScoreItemListRequest = protobuf.Message(GETMALLSCOREITEMLISTREQUEST)
GetMallScoreItemListResponse = protobuf.Message(GETMALLSCOREITEMLISTRESPONSE)
GetMallTabsRequest = protobuf.Message(GETMALLTABSREQUEST)
GetMallTabsResponse = protobuf.Message(GETMALLTABSRESPONSE)
MallItem = protobuf.Message(MALLITEM)
MallScoreItem = protobuf.Message(MALLSCOREITEM)
MallTab = protobuf.Message(MALLTAB)
