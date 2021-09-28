--region TipInfoScene.lua
--Author : shizm
--Date   : 2014/10/14
--此文件由[BabeLua]插件自动生成

require("app.cfg.tips_info")

--endregion
local TipsInfoData = {}

-- @得到一级界面
function TipsInfoData.getListData1()
    local list = {}
    for i=1,tips_info.getLength() do
        local data = tips_info.indexOf(i)
        if data then
            if data.premise_id == 0 then
                table.insert(list, data)
            end
        end
    end
    return list
end

-- @得到二级,三级界面列表
function TipsInfoData.getListData2And3(premise_id)
    local list = {}
    for i=1,tips_info.getLength() do
        local data = tips_info.indexOf(i)
        if data then
            if data.premise_id == premise_id then
                table.insert(list, data)
            end
        end
    end
    return list
end

return TipsInfoData
