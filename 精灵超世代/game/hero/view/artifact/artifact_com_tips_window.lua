--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-16 16:01:46
-- @description    : 
		-- 符文合成的tips
---------------------------------
ArtifactComTipsWindow = ArtifactComTipsWindow or BaseClass(BaseView)

local _controller = HeroController:getInstance()

function ArtifactComTipsWindow:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/artifact_com_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips    
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
end

function ArtifactComTipsWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.container = self.main_panel:getChildByName("container")

    -- 基础属性,名字,类型
    self.base_panel = self.container:getChildByName("base_panel")
    self.equip_item =  BackPackItem.new(true,true,nil,1,false)
    self.equip_item:setPosition(cc.p(72,68))
    self.base_panel:addChild(self.equip_item)
    self.name = self.base_panel:getChildByName("name")
    self.equip_type = self.base_panel:getChildByName("equip_type")

    -- 可能出现的属性
    self.baseattr_panel = self.container:getChildByName("baseattr_panel")
    self.attr_text = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(14, 90), 15, nil, 370)
    self.baseattr_panel:addChild(self.attr_text)

    -- 间隔线
    self.line = self.container:getChildByName("line")

    -- 可能出现的符文技能
    self.skill_panel = self.container:getChildByName("skill_panel")
    self.skill_text = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(14, 190), 8, nil, 370)
    self.skill_panel:addChild(self.skill_text)

    self.close_btn = self.container:getChildByName("close_btn")
end

function ArtifactComTipsWindow:register_event(  )
	registerButtonEventListener(self.background, function ( )
		_controller:openArtifactComTipsWindow(false)
	end, false, 2)

	registerButtonEventListener(self.close_btn, function ( )
		_controller:openArtifactComTipsWindow(false)
	end, false, 2)
end

function ArtifactComTipsWindow:openRootWnd( bid )
	self.artifact_bid = bid
	self:setBaseInfo()
	self:setAttrAndSkillInfo()
end

-- 基础信息
function ArtifactComTipsWindow:setBaseInfo(  )
	if not self.artifact_bid then return end

	local item_config = Config.ItemData.data_get_data(self.artifact_bid)

	if not item_config then return end

	self.equip_item:setBaseData(self.artifact_bid)

	local quality = 0
    if item_config.quality >= 0 and item_config.quality <= 5 then
        quality = item_config.quality
    end
    --local background_res = PathTool.getResFrame("tips", "tips_"..quality)
    --loadSpriteTexture(self.base_panel, background_res, LOADTEXT_TYPE_PLIST)
    local color = BackPackConst.getEquipTipsColor(quality)
    self.name:setTextColor(color) 
    self.name:setString(item_config.name)

    self.equip_type:setString(TI18N("类型：")..item_config.type_desc)
end

-- 属性和技能文字显示
function ArtifactComTipsWindow:setAttrAndSkillInfo(  )
	if not self.artifact_bid then return end

	local art_base_cfg = Config.PartnerArtifactData.data_artifact_data[self.artifact_bid]

	if not art_base_cfg then return end

	self.attr_text:setString(art_base_cfg.arrt_desc or "")
	self.skill_text:setString(art_base_cfg.skill_desc or "")

	-- 调整大小
	local container_size = self.container:getContentSize()
	local base_panel_size = self.base_panel:getContentSize()

	local arrt_panel_height = 50
	local attr_text_size = self.attr_text:getSize()
	arrt_panel_height = arrt_panel_height + attr_text_size.height

	local skill_panel_height = 50
	local skill_text_size = self.skill_text:getSize()
	skill_panel_height = skill_panel_height + skill_text_size.height

	local top_space = 4
	local line_space = 10 -- 间隔线的空间
	local bottom_space = 30 -- 底部空间

	container_size.height = top_space + base_panel_size.height + arrt_panel_height + line_space + skill_panel_height + bottom_space
	self.container:setContentSize(container_size)

	self.base_panel:setPositionY(container_size.height - top_space)
	self.baseattr_panel:setPositionY(container_size.height - top_space - base_panel_size.height)
	self.line:setPositionY(container_size.height - top_space - base_panel_size.height - arrt_panel_height - line_space/2)
	self.skill_panel:setPositionY(bottom_space + skill_panel_height)
	self.close_btn:setPositionY(container_size.height - 25)
end

function ArtifactComTipsWindow:close_callback(  )
    if self.equip_item then
        self.equip_item:DeleteMe()
        self.equip_item = nil
    end
    _controller:openArtifactComTipsWindow(false)
end