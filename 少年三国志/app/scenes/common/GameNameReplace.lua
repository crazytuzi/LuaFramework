local GameNameReplace = {}


function GameNameReplace._replace(str, targetName)
    return string.gsub(str, "少年三国志", targetName)
end

function GameNameReplace._replaceCfgRecords(cfg, keys, columns, targetName)
    local len = cfg.getLength()
    for i=1,len do 
        local record = cfg.indexOf(i)
        local vals = {}
        for _,k in ipairs(keys) do
            table.insert(vals, record[k])
        end
        table.insert(vals, "column")
        table.insert(vals, "replacement")

        for j,column in ipairs(columns) do 
            if string.find(record[column], "少年三国志") ~= nil then
                local replacement = GameNameReplace._replace( record[column], targetName)
                vals[#vals-1] = column
                vals[#vals] = replacement
                -- print("set " .. column .. "->" .. replacement)
                 cfg.set(unpack(vals))
            end
            
        end
    end
end


function GameNameReplace.replaceAllCfg(targetName)
    require("app.cfg.arena_chat_info")
    GameNameReplace._replaceCfgRecords(arena_chat_info, {"id"} , {"chat"},  targetName)

    require("app.cfg.share_info")
    GameNameReplace._replaceCfgRecords(share_info, {"id"} , {"share_content"},  targetName)

    require("app.cfg.story_dialogue")
    GameNameReplace._replaceCfgRecords(story_dialogue, {"story_id", "step"} , {"substance"},  targetName)

    require("app.cfg.vip_daily_boon")
    GameNameReplace._replaceCfgRecords(vip_daily_boon,{"id"} , {"talk_1"},  targetName)
end




return GameNameReplace




