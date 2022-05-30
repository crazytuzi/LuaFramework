-- --------------------------------------------------------------------
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      萌宠功能 后端锋林  策划 中健
-- <br/>Create: 2019-06-28
HomepetEvent = HomepetEvent or {}


--宠物对象属性更新事件
HomepetEvent.HOME_PET_VO_ATTR_EVENT = "HomepetEvent.HOME_PET_VO_ATTR_EVENT"

--宠物出行有产生事件
HomepetEvent.HOME_PET_GO_OUT_NEW_EVENT = "HomepetEvent.HOME_PET_GO_OUT_NEW_EVENT"

--行囊背包更新
HomepetEvent.HOME_PET_TRAVELLING_BAG_UPDATE_EVENT = "HomepetEvent.HOME_PET_TRAVELLING_BAG_UPDATE_EVENT"
--行囊选择道具回调事件
HomepetEvent.HOME_PET_SELECT_ITEM_CALLBACK_EVENT = "HomepetEvent.HOME_PET_SELECT_ITEM_CALLBACK_EVENT"

--检测事件触发
HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT = "HomepetEvent.HOME_PET_CHECK_TRIGGER_EVENT"

--宠物旅行中
HomepetEvent.HOME_PET_TRAVELLING_EVENT = "HomepetEvent.HOME_PET_TRAVELLING_EVENT"

-- 获取本次出行所有事件
HomepetEvent.HOME_PET_THIS_TIME_ALL_EVENT = "HomepetEvent.HOME_PET_THIS_TIME_ALL_EVENT"

--删除图片
HomepetEvent.HOME_PET_DELETE_PHOTO_EVENT = "HomepetEvent.HOME_PET_DELETE_PHOTO_EVENT"
--删除日记
HomepetEvent.HOME_PET_DELETE_LETTER_EVENT = "HomepetEvent.HOME_PET_DELETE_LETTER_EVENT"
--宠物聊天
HomepetEvent.HOME_PET_TALK_EVENT = "HomepetEvent.HOME_PET_TALK_EVENT"
