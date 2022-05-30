-- --------------------------------------------------------------------
-- 符文重铸消耗选择界面
-- 
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-3-20
-- --------------------------------------------------------------------
ArtifactRecastCostPanel = ArtifactRecastCostPanel or BaseClass(BaseView)

function ArtifactRecastCostPanel:__init()
    self.ctrl = HeroController:getInstance()
    self.is_full_screen = false
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("artifact", "artifact"), type = ResourcesType.plist},
    }
    self.layout_name = "hero/artifact_recast_cost_panel"
    

end

function ArtifactRecastCostPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end


    self.main_container = self.root_wnd:getChildByName("main_container")
    -- 通用进场动效
    ActionHelp.itemScaleAction(self.main_container)

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.cost_btn_1 = self.main_container:getChildByName("cost_btn_1")
    self.cost_btn_1:getChildByName("label"):setString(TI18N("确认选择"))
    self.cost_btn_2 = self.main_container:getChildByName("cost_btn_2")
    self.cost_btn_2:getChildByName("label"):setString(TI18N("确认选择"))
    self.main_container:getChildByName("win_title"):setString(TI18N("选择提示"))
    self.main_container:getChildByName("Text_7"):setString(TI18N("选择一种您要使用的道具"))
    
    self.left_item = BackPackItem.new(true,true,nil)
    self.left_item:setPosition(cc.p(180,300))
    self.main_container:addChild(self.left_item)
    
    self.right_item = BackPackItem.new(true,true,nil)
    self.right_item:setPosition(cc.p(484,300))
    self.main_container:addChild(self.right_item)
    
    self.desc_label_1 = createRichLabel(22,cc.c4b(0x95,0x53,0x22,0xff),cc.p(0.5, 0.5),cc.p(180, 160),10, nil,280)
    self.main_container:addChild(self.desc_label_1)
    self.desc_label_1:setString(TI18N("出现强力和稀有技能\n          <div fontcolor=#249003>概率翻倍</div>！"))
    
    self.desc_label_2 = createRichLabel(22,cc.c4b(0x95,0x53,0x22,0xff),cc.p(0.5, 0.5),cc.p(484, 160),10, nil,280)
    self.main_container:addChild(self.desc_label_2)
    self.desc_label_2:setString(TI18N("<div fontcolor=#249003>必定</div>出现<div fontcolor=#249003>双高级</div>技能！"))

end

function ArtifactRecastCostPanel:register_event()
    registerButtonEventListener(self.close_btn, function() 
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Cost_Select_Event)
        self.ctrl:openArtifactRecastCostPanel(false)
    end, true, 2)

    registerButtonEventListener(self.background, function() 
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Cost_Select_Event)
        self.ctrl:openArtifactRecastCostPanel(false)
    end, false, 2)

    registerButtonEventListener(self.cost_btn_1, function() 
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Cost_Select_Event, 1)
        self.ctrl:openArtifactRecastCostPanel(false)
    end, true, 1)

    registerButtonEventListener(self.cost_btn_2, function() 
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Cost_Select_Event, 2)
        self.ctrl:openArtifactRecastCostPanel(false)
    end, true, 1)
end



function ArtifactRecastCostPanel:openRootWnd()
    self:initData()
end


function ArtifactRecastCostPanel:initData()
    local lucky_item_id_config = Config.PartnerArtifactData.data_artifact_const.lucky_item_id
    local lucky_item_id_config2 = Config.PartnerArtifactData.data_artifact_const.lucky_item_id2
    
    if lucky_item_id_config and lucky_item_id_config2 then
        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config.val)
        local have_num2 = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config2.val)
        self.left_item:setBaseData(lucky_item_id_config.val,have_num)
        
        self.right_item:setBaseData(lucky_item_id_config2.val,have_num2)
        
        local config_1 = Config.ItemData.data_get_data(lucky_item_id_config.val)
        if config_1 then
            self.left_item:addCallBack(function (  )
                TipsManager:getInstance():showGoodsTips(config_1, true)
            end)
            self.left_item:setGoodsName(config_1.name,cc.p(BackPackItem.Width/2,-33),24,BackPackConst.quality_color[config_1.quality])    
        end

        local config_2 = Config.ItemData.data_get_data(lucky_item_id_config2.val)
        if config_2 then
            self.right_item:addCallBack(function (  )
                TipsManager:getInstance():showGoodsTips(config_2, true)
            end)
            self.right_item:setGoodsName(config_2.name,cc.p(BackPackItem.Width/2-1,-33),24,BackPackConst.quality_color[config_2.quality])    
        end
    end
end



function ArtifactRecastCostPanel:close_callback()
    doStopAllActions(self.main_container)
    if self.left_item then
        self.left_item:DeleteMe()
        self.left_item = nil
    end
    if self.right_item then
        self.right_item:DeleteMe()
        self.right_item = nil
    end
    self.ctrl:openArtifactRecastCostPanel(false)
end







