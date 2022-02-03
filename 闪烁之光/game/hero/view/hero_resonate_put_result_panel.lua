-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      共鸣水晶放入的英雄
-- <br/> 2020年3月6日
-- --------------------------------------------------------------------
HeroResonatePutResultPanel = HeroResonatePutResultPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil


function HeroResonatePutResultPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/hero_resonate_put_result_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("planes","planes_map"), type = ResourcesType.plist }
    }
    
end

function HeroResonatePutResultPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
   
    self.left_lv = self.main_container:getChildByName("left_lv")
    self.right_lv = self.main_container:getChildByName("right_lv")
    self.left_lv:setString("")
    self.right_lv:setString("")
    self.tips = self.main_container:getChildByName("tips")
    self.tips:setString(TI18N("英雄已被提升至水晶等级"))

    self.item_node = self.main_container:getChildByName("item_node")
    self:handleEffect(true)
    self.right_item_node = self.main_container:getChildByName("right_item_node")

    self.hero_item = HeroExhibitionItem.new(1, false, 0, false) 
    self.item_node:addChild(self.hero_item)

end

function HeroResonatePutResultPanel:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.item_node) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(145), cc.p(0,0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.item_node:addChild(self.play_effect, -1)
        end
    end
end 

function HeroResonatePutResultPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
end

--关闭
function HeroResonatePutResultPanel:onClickBtnClose()
    controller:openHeroResonatePutResultPanel(false)
end

--hero_vo
function HeroResonatePutResultPanel:openRootWnd(hero_vo)
    self.hero_vo = hero_vo
    if not self.hero_vo then return end
    self.hero_item:setData(self.hero_vo)

    self.left_lv:setString("Lv."..self.hero_vo.resonate_lev)
    self.right_lv:setString("Lv."..self.hero_vo.lev)
end


function HeroResonatePutResultPanel:close_callback()

    if self.hero_item then
        self.hero_item:DeleteMe()
        self.hero_item = nil
    end
    self:handleEffect(false)

    controller:openHeroResonatePutResultPanel(false)
end
