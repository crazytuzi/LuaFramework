--[[
 --
 -- add by vicky
 -- 2015.01.04 
 --
 --]]


GuildBottomBtnEvent = {}

GuildBottomBtnEvent.canTouchEnabled = true 

local BOTTOM_BTN_TYPE = {
    manager = 1,    -- 管理 
    member = 2,     -- 成员
    chat = 3,       -- 聊天
    dynamic = 4,    -- 动态
    back = 5,       -- 返回
    fuli = 6,       -- 福利
}

local MAX_ZORDER = 100 

-- 管理、成员、聊天、动态、返回 
local btnNames = {"manager_btn", "member_btn", "chat_btn", "dynamic_btn", "back_btn", "fuli_btn"} 

function GuildBottomBtnEvent.setTouchEnabled(bEnabled)
    GuildBottomBtnEvent.canTouchEnabled = bEnabled 
end


function GuildBottomBtnEvent.registerBottomEvent(btnMaps)
    -- dump(btnMaps) 

    local function onTouchBtn(sender) 
        if GuildBottomBtnEvent.canTouchEnabled ~= nil and GuildBottomBtnEvent.canTouchEnabled == true then  
            
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 

            local nextState  
            local tag = sender:getTag() 
            dump(tag) 
            if tag == BOTTOM_BTN_TYPE.manager then 
                game.runningScene:addChild(require("game.guild.GuildManagerLayer").new(), MAX_ZORDER)  

            elseif tag == BOTTOM_BTN_TYPE.member then 
                nextState = GAME_STATE.STATE_GUILD_ALLMEMBER 

            elseif tag == BOTTOM_BTN_TYPE.chat then 
                show_tip_label("暂未开放")

            elseif tag == BOTTOM_BTN_TYPE.dynamic then 
                nextState = GAME_STATE.STATE_GUILD_DYNAMIC 

            elseif tag == BOTTOM_BTN_TYPE.back then 
                nextState = GAME_STATE.STATE_MAIN_MENU 

            elseif tag == BOTTOM_BTN_TYPE.fuli then 
                local function toList(data)
                    game.runningScene:addChild(require("game.guild.guildFuli.GuildFuliLayer").new(data), MAX_ZORDER) 
                end 
                game.player:getGuildMgr():RequestFuliList(toList) 
            end  

            if nextState ~= nil then 
                GameStateManager:ChangeState(nextState) 
            end 
        end 
    end

    for i, v in ipairs(btnNames) do 
        if btnMaps[v] ~= nil then 
            btnMaps[v]:addHandleOfControlEvent(function(eventName, sender)
                onTouchBtn(sender) 
            end, CCControlEventTouchUpInside)
        end     
    end  

end

return GuildBottomBtnEvent
