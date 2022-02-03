-- --------------------------------------------------------------------
-- 关注贴吧公众号
-- --------------------------------------------------------------------
PastePanel = class("PastePanel", function()
	return ccui.Widget:create()
end) 

function PastePanel:ctor()
    self.item_list = {}
    self:createRootWnd()
end

function PastePanel:createRootWnd()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/paste_panel"))
	self:addChild(self.root_wnd)
	self:setPosition(-40, -80)
	self:setAnchorPoint(0, 0)

    WelfareController:getInstance():setPosteWelfareStatus(false)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:getChildByName("txt1"):setString(TI18N("贴吧搜索:"))
    self.main_container:getChildByName("txt2"):setString(TI18N("点击关注"))
    self.main_container:getChildByName("txt3"):setString(TI18N("进入「关注礼包码贴」领取礼包码"))

    self.item_cons = self.main_container:getChildByName("item_cons")
    self.bg = self.main_container:getChildByName("bg")
    
    -- 加载背景
    self:loadBackground()
    -- 奖励物品
    self:showItemList()
end

function PastePanel:loadBackground()
    local bg_path = PathTool.getPlistImgForDownLoad("bigbg/welfare", "txt_cn_paste")
    self.load_bg = loadSpriteTextureFromCDN(self.bg, bg_path, ResourcesType.single)
end
function PastePanel:showItemList()
	local data_list = Config.HolidayClientData.data_info
	local list = data_list[WelfareIcon.poste]
	if list then
		for i, v in ipairs(list.items) do
			if self.item_list[i] == nil then
				self.item_list[i] = BackPackItem.new(false, true, false, 1, false, true)
				self.item_cons:addChild(self.item_list[i])
				self.item_list[i]:setPosition(77 +(i - 1) * 138, 77)
			end
			local item = self.item_list[i]
			item:setBaseData(v[1], v[2])
		end
	end
end

function PastePanel:setVisibleStatus(status)
	bool = bool or false
	self:setVisible(status)
end

function PastePanel:DeleteMe()
    if self.load_bg then
        self.load_bg:DeleteMe()
    end
    self.load_bg = nil

    if self.item_list then
        for k,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
end