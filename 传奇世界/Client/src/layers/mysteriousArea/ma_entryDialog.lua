local ma_entryDialog = class("ma_entryDialog", function() return cc.Node:create() end)
local key_protoId = 999
local bag = MPackManager:getPack(MPackStruct.eBag)

function ma_entryDialog:ctor(t)
    local bg = createBgSprite(self, game.getStrByKey("mysteriousArea_title"))
    local spr_bg = cc.Sprite:create("res/layers/mysteriousArea/bg.jpg")
    spr_bg:setPosition(cc.p(481, 288))
    bg:addChild(spr_bg)
    Mnode.createColorLayer(
	{
		parent = bg,
		src = cc.c4b(0, 0, 0, 255 * 0.5),
		cSize = cc.size(400, 200),
		anchor = cc.p(0, 0),
		pos = cc.p(34, 38),
	})
    local posY_baseLine = 84
    __createHelp(
	{
		parent = bg,
		str = require("src/config/PromptOp"):content(72),
		pos = cc.p(375, posY_baseLine),
	})
    local resetBtn = createMenuItem(bg, "res/component/button/48.png", cc.p(100, posY_baseLine), function()
        if bag:countByProtoId(key_protoId) <= 0 then
            TIPS(getConfigItemByKeys("clientmsg", {"sth", "mid"}, {38000, -2}))     --提示需要钥匙
            return
        end
        if not G_MYSTERIOUS_NOT_SHOW_AGAIN_STETE.use_key_to_reset then
            local tempLayer
            tempLayer = MessageBoxYesNo(nil, game.getStrByKey("mysteriousArea_reset_will_comsume_key_confirm"), function()
                G_MYSTERIOUS_NOT_SHOW_AGAIN_STETE.use_key_to_reset = (tempLayer.checkBox:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
                g_msgHandlerInst:sendNetDataByTable(MAZE_CS_RESET_REQ, "ResetMazeReq", {})
            end, nil)
    	    tempLayer.checkBox = createTouchItem(tempLayer, "res/component/checkbox/1.png", cc.p(170, 110), function(sender)
                sender:setTexture(sender:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1.png") and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png")
		    end)
    	    createLabel(tempLayer, game.getStrByKey("ping_btn_no_more"), cc.p(195, 110), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black, nil, nil, MColor.black, 3)
        else
    	    g_msgHandlerInst:sendNetDataByTable(MAZE_CS_RESET_REQ, "ResetMazeReq", {})
        end
    end)
    local label_font_size = 20
    createLabel(resetBtn, game.getStrByKey("fb_reset"), getCenterPos(resetBtn), cc.p(0.5, 0.5), label_font_size, true)
    local line_height = 22
    local richTextDescriptionSize_width = 350
    local richText_cost_description_line_1 = require("src/RichText").new(bg, cc.p(52, 155 + 40), cc.size(richTextDescriptionSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_cost_description_line_1:setAutoWidth()
    richText_cost_description_line_1:addText(game.getStrByKey("mysteriousArea_gamePlay_description_1"))
    richText_cost_description_line_1:format()
    local richText_cost_description_line_2 = require("src/RichText").new(bg, cc.p(52, 155), cc.size(richTextDescriptionSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
    richText_cost_description_line_2:setAutoWidth()
    richText_cost_description_line_2:addText(game.getStrByKey("mysteriousArea_gamePlay_description_2"))
    richText_cost_description_line_2:format()
    local tag_richText = 890
    local MPackManager = require "src/layers/bag/PackManager"
    local MPackStruct = require "src/layers/bag/PackStruct"
    function refreshText()
        bg:removeChildByTag(tag_richText)
        local own_num_item = bag:countByProtoId(key_protoId)
        local line_height = 24
        local richTextSize_width = 960
        local richText_cost_key = require("src/RichText").new(bg, cc.p(150, posY_baseLine), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
        richText_cost_key:setTag(tag_richText)
        richText_cost_key:setAutoWidth()
        richText_cost_key:addText(
            "^c(lable_black)" .. game.getStrByKey("own") .. ":^"
        )
        local spr_key = cc.Sprite:create("res/layers/mysteriousArea/iocn2.png")
        spr_key:setScale(0.7)
        richText_cost_key:addNodeItem(spr_key, false)
        richText_cost_key:addText(
            "x" .. own_num_item
        )
        richText_cost_key:format()
    end
    local func_changed_item = function(observable, event, pos, pos1, new_grid)
        if not (event == "-" or event == "+" or event == "=") then return end
        refreshText()
    end
    self:registerScriptHandler(function(event)
	    if event == "enter" then
            bag:register(func_changed_item)
	    elseif event == "exit" then
            bag:unregister(func_changed_item)
	    end
    end)
    refreshText()
    require("src/component/button/MenuButton").new(
    {
	    parent = bg,
	    pos = cc.p(816, posY_baseLine),
        src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	    label = {
		    src = game.getStrByKey("mysteriousArea_entry_dialog_btn_enter_title"),
		    size = label_font_size,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
            g_msgHandlerInst:sendNetDataByTable(MAZE_CS_ENTER_REQ, "EnterMazeReq", {})
	    end,
    })
    --显示领取界面
    if t.dailyPrized ~= 1 then
        return
    end
    Awards_Panel({awards = {{num = 10, id = 999}}, award_tip = game.getStrByKey("get_awards")})
end

return ma_entryDialog