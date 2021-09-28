local VSCreateTeamNode = class("VSCreateTeamNode", function() return cc.Layer:create() end);

function VSCreateTeamNode:ctor()
    
    ---------------------------------------------------------------------------------------------------------------------------------------
    local commConst = require("src/config/CommDef");
    getRunScene():addChild(self, commConst.ZVALUE_UI);
    self:setTag(commConst.TAG_3V3_CREATE_TEAM_DIALOG)

    self.m_baseNode = createSprite( self, "res/common/bg/bg18.png", cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ) );
    local bgSize = self.m_baseNode:getContentSize();
    
    local nameLal = createLabel(self.m_baseNode, game.getStrByKey("p3v3_create_team"), cc.p(850/2, 529-25),cc.p(0.5, 0.5), 28, true, nil, nil, MColor.lable_yellow, 12580)

    local centerSpr = createScale9Frame(
        self.m_baseNode,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )

    ---------------------------------------------------------------------------------------------------------------------------------------
    self.m_editBg = createSprite(centerSpr, "res/createRole/nameBg1.png", cc.p(centerSpr:getContentSize().width/2, 370), cc.p(0.5, 0));
    local editBgSize = self.m_editBg:getContentSize();

	local function editBoxTextEventHandle(strEventName,pSender)
	 	local edit = tolua.cast(pSender,"ccui.EditBox") 

        if strEventName == "began" then --编辑框开始编辑时调用

        elseif strEventName == "ended" then --编辑框完成时调用

        elseif strEventName == "return" then --编辑框return时调用
        	log("return")
        	local str = edit:getText()
        	if str ~= "" then
        		self.inputName = str
        	end
        	self:UpdateNameCtrlPos()
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	log("changed")
        	self:UpdateNameCtrlPos()
        end
	end

    local editBgSize = self.m_editBg:getContentSize();
	self.m_teamNameCtrl = createEditBox(self.m_editBg, nil, cc.p((editBgSize.width-176)/2, editBgSize.height/2), cc.size(176, 34), MColor.white, 24, game.getStrByKey("p3v3_create_team_place_holder_text"))
	self.m_teamNameCtrl:setAnchorPoint(cc.p(0, 0.5))
    self.m_teamNameCtrl:setText("")
    self.m_teamNameCtrl:setFontColor(MColor.lable_yellow);
    self.m_teamNameCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.m_teamNameCtrl:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    self.m_teamNameCtrl:registerScriptEditBoxHandler(editBoxTextEventHandle)

    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    createLabel(centerSpr, game.getStrByKey("p3v3_create_team_red_text"), cc.p(centerSpr:getContentSize().width/2, 330),cc.p(0.5, 0), 20, true, nil, nil, MColor.red);

    ---------------------------------------------------------------------------------------------------------------------------------------

    local currencyIcons = 
    {
        [1] = "1.png",
        [2] = "2.png",
        [3] = "3.png",
        [4] = "4.png",
    }

    local currencyIds = 
    {
        [1] = PLAYER_MONEY,
        [2] = PLAYER_BINDMONEY,
        [3] = PLAYER_INGOT,
        [4] = PLAYER_BINDINGOT,
    }

    local costNode = Mnode.combineNode(
	{
		nodes = {
			Mnode.createLabel(
			{
				src = game.getStrByKey("consume") .. ": ",
				color = MColor.lable_yellow,
				size = 20,
				outline = false,
			}),
			
			Mnode.createSprite(
			{
				src = "res/group/currency/" .. currencyIcons[1],
				scale = 0.65,
			}),
			
			Mnode.createLabel(
			{
				src = "30万",
				size = 20,
				color = MColor.lable_yellow,
				outline = false,
			}),
		},
	})
		
	Mnode.addChild(
	{
		parent = centerSpr,
		child = costNode,
		pos = cc.p(150, 200),
        anchor = cc.p(0, 0),
	})

    ---------------------------------------------------------------------------------------------------------------------------------------
    local Mcurrency = require "src/functional/currency"
    local ownNode = Mnode.combineNode(
	{
		nodes = {
            Mnode.createLabel(
			{
				src = game.getStrByKey("own") .. ": ",
				color = MColor.lable_yellow,
				size = 20,
				outline = false,
			}),
            -- 货币
		    Mcurrency.new(
		    {
			    cate = currencyIds[1],
			    color = MColor.lable_yellow,
                unit = 10000, -- 可选
                margin = 4, -- 可选
                scale = 0.65, -- icon 缩放的缩放系数
		    }),
        }
	})

    Mnode.addChild(
	{
		parent = centerSpr,
		child = ownNode,
		pos = cc.p(500, 200),
        anchor = cc.p(0, 0),
	})
    

    local buttomSpr = createSprite(centerSpr, "res/layers/DragonSliayer/5.png", cc.p(5, 6), cc.p(0, 0));
    
	local challengeBtn = createMenuItem(buttomSpr, "res/component/button/2.png", cc.p(buttomSpr:getContentSize().width/2, 40), function()
        self:SendCreateMsg();
	end)
	createLabel(challengeBtn, game.getStrByKey("p3v3_create_team"), getCenterPos(challengeBtn), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow);

    -- 关闭按钮
    local closeBtn = createMenuItem( self.m_baseNode, "res/component/button/X.png", cc.p(bgSize.width-50, bgSize.height-28), function()
        removeFromParent(self);
    end)

    registerOutsideCloseFunc(self, function()
        
        end, true)
end

function VSCreateTeamNode:SendCreateMsg()
    local txt = self.m_teamNameCtrl:getText()
    if self:CheckNameRule(txt) == false then
		return;
	end

    local proto = {};
    proto.name = txt;
	g_msgHandlerInst:sendNetDataByTableExEx(FIGTHTEAM_CS_CREATE, "FightTeamCreateProtocol", proto);
end

-- 1：不能以空格开头、也不能以空格结尾
-- 2：不能以传奇世界、传世、GM、gm、官方、活动XX、宣传XX、推广XX、
-- 3：取名不支持换行
function VSCreateTeamNode:CheckNameRule(name)
    if name == nil or type(name) ~= "string" or string.len(name) <=0 then
		TIPS({ type = 1 , str = game.getStrByKey("p3v3_team_name_nil") , isMustShow = true})
		return false;
	end

	if string.find(name, " ") or string.find(name, "\n") or string.find(name, "\r") or string.find(name, "%^") then
		TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
		return false;
	end

	if string.utf8sub(name, 0, 1) == " " then
		TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_1") , isMustShow = true})
		return false
	elseif string.utf8sub(name, -1) == " " then
		TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_1") , isMustShow = true})
		return false
	end

	local word = {"传奇世界", "传世", "GM", "gm", "官方", "活动", "宣传", "推广"}
	for i,v in ipairs(word) do
		if string.find(name, v) then
			TIPS({ type = 1 , str = game.getStrByKey("invilid_symbol") , isMustShow = true})
			return false
		end
	end

	if string.find(name, "\n") or string.find(name, "\r") then
		TIPS({ type = 1 , str = game.getStrByKey("role_name_rule_3") , isMustShow = true})
		return false
	end

    if DirtyWords:isHaveDirytWords(name) then
        TIPS({ type = 1 , str = game.getStrByKey("invilid_namelen_ex") , isMustShow = true})
		return false;
    end

	return true
end

function VSCreateTeamNode:UpdateNameCtrlPos()
	local str = self.m_teamNameCtrl:getText();
	if str == "" then
		str = game.getStrByKey("create_input_name")
	end
	local label = createLabel(nil, str, cc.p(0, 0), cc.p(0, 0), 24)
	
	local x = self.m_editBg:getContentSize().width/2 - label:getContentSize().width/2
    
	self.m_teamNameCtrl:setPosition(cc.p(x, self.m_editBg:getContentSize().height/2))
end

return VSCreateTeamNode;