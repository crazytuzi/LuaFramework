-- --------------------------------------------------------------------
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      萌宠功能 后端锋林  策划 中健
-- <br/>Create: 2019-06-28
HomepetConst = HomepetConst or {}


--背包显示类型
HomepetConst.Item_bag_show_type = {
    eBagItemType = 1, --道具背包类型
    eSelectFoodType = 2, --选择食物类型
    eSelectItemType = 3, --选择道具类型
}

--背包页面页签
HomepetConst.Item_bag_tab_type = {
    eFoodType = 1, --食物
    eItemType = 2, --道具
    eTreasureType = 3, --珍品 特产等特殊道具
}

--收藏页面页签
HomepetConst.collection_tab_type = {
    eTreasureType = 1, --珍品 特产等特殊道具
    ePhotoType = 2, --相册
    eLetterType = 3, --书信
}

--萌宠 事件类型
HomepetConst.event_type = {
    eGoEvent       = 0,  --出去回来事件
    ePhoto         = 6, --相册事件
    eLetter        = 7, --书信事件
}

--萌宠状态类型(服务端定义的)
HomepetConst.state_type = {
    eNotActive     = 0,  --未激活
    eHome         = 1, --在家
    eOnWay        = 2, --在路上旅行中
}