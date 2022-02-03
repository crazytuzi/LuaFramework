-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      主界面小地图
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaFuncItem =
    class(
    'BattleDramaFuncItem',
    function()
        return ccui.Layout:create()
    end
)
BattleDramaFuncItem.WIDTH = 600
BattleDramaFuncItem.HEIGHT = 136
function BattleDramaFuncItem:ctor(is_bool, is_bools, size)
    self:retain()
    self.size = size or cc.size(BattleDramaFuncItem.WIDTH, BattleDramaFuncItem.HEIGHT)
    self:setContentSize(self.size)
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB('battledrama/battle_drama_open_func_item'))
    self:addChild(self.root_wnd)
    self.container = self.root_wnd:getChildByName('root')
    self.name_label = self.container:getChildByName("name_label")
    self.icon = self.container:getChildByName("icon")
    self.icon:setScale(0.5)
    self.desc_label = self.container:getChildByName("desc_label")
    self.desc_label_2 = self.container:getChildByName("desc_label_2")
    self.show_icon = self.container:getChildByName("show_icon")
    self.show_icon:setVisible(false)
    self.desc_label_3 = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(495,95), nil, nil, 1000)
    self.desc_label_3:setVisible(false)
    self.container:addChild(self.desc_label_3)

    self.item_list = {}
    self:registerEvent()
end

function BattleDramaFuncItem:registerEvent()
end

function BattleDramaFuncItem:setData(data)
    if data then
        local config = Config.DungeonData.data_drama_dungeon_info(data.limit_id)
        if config  then
            self.desc_label_2:setString(TI18N("通关")..config.name)
        end
        self.name_label:setString(data.unlock_name)
        local offset_num =  BattleDramaController:getInstance():getModel():getOffsetNum(data.limit_id) - BattleDramaController:getInstance():getModel():getCurDungeonMaxNum()
        local str = ""
        if offset_num > 0 then
            str = string.format(TI18N('<div fontcolor=#289b14>%s</div><div fontcolor=#a95a1d>关后开启</div>'), offset_num)
        else
            str = ""
        end
        if data.has_open == TRUE then
            self.show_icon:setVisible(true)
            self.desc_label_3:setVisible(false)
        else
            self.desc_label_3:setString(str)
            self.show_icon:setVisible(false)
            self.desc_label_3:setVisible(true)
        end
       

        local title_id = PathTool.getPlistImgForDownLoad('bigbg/battledrama', data.unlock_icon)
        if self.res_id_2 ~= title_id then
            self.res_id_2 = title_id
            self.item_load_1 = createResourcesLoad(self.res_id_2,ResourcesType.single,function()
                if not tolua.isnull(self.icon) then
                    loadSpriteTexture(self.icon, self.res_id_2, LOADTEXT_TYPE)
                end
            end, self.item_load_1)
        end
        self.desc_label:setString(data.desc)
    end
end

function BattleDramaFuncItem:updateItem(data)
    if not data then
        return
    end
end

function BattleDramaFuncItem:DeleteMe()
    if self.item_load_1 then
        self.item_load_1:DeleteMe()
        self.item_load_1 = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
    self:release()
end
