-- Filename: EquipAwakeController.lua
-- Author: FQQ
-- Date: 2016-01-04
-- Purpose:装备觉醒控制器

module ("EquipAwakeController",package.seeall)
require "script/ui/hero/equipAwake/EquipAwakeService"
require "script/model/hero/HeroModel"
--[[
    @des    : 激活主角天赋
    @param  : 
    @return : 
--]] 
function activeMasterTalent( index, talentId, pCallback )
    local requestCallback = function ( pRecData )
        if(pRecData == "ok")then
            --修改武将的觉醒能力
            local hid = UserModel.getUserHid()
            HeroModel.setMasterTalentId( hid, index, talentId )

            local callback = function ( ... )
                if pCallback then
                    pCallback()
                end
            end
            -- -- --修改武将可装备的天赋
            getArrMasterTalent(callback)
        else
            print("error")
        end
    end
    EquipAwakeService.activeMasterTalent(index, talentId,requestCallback)
end


--[[
    @des    : 获取主角可装备的天赋
    @param  : 
    @return : 
--]] 
function getArrMasterTalent(pCallback)
    local  requestCallback = function( pRecData )
        EquipAwakeData.setEquipAwakeInfo(pRecData)
        if pCallback then
            pCallback()
        end
    end
    EquipAwakeService.getArrMasterTalent(requestCallback)
end


