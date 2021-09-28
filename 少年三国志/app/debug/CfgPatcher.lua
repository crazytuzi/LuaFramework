
local CfgPatcher  = {}

CfgPatcher.writePath = CCFileUtils:sharedFileUtils():getWritablePath() .. "client_cfg/"
CfgPatcher.check_md5 = true
function CfgPatcher.check_patch() 
    -- print("======================check_patch" .. getRealVersionNo())
    local patch_url = G_Setting:get("client_cfg_patch_url")
    -- patch_url = 'http://10.3.99.16/nconfig/services/nconfig?action=get_content&md5=caaed11e74f055fe05483a91f08070dc&version=10800'
    -- http://sspatch.icantw.com/nconfig/services/nconfig?action=get_content&md5=a230d8035a77d5e7fc0bf409cb4eba77&version=10663
    if patch_url then
        local md5 = string.match(patch_url ,"md5=(%w+)") 
        local version = string.match(patch_url ,"version=(%d+)") 
        if md5 ~= nil and version ~= nil then
            if tostring(version) == tostring(getRealVersionNo()) then
                FuncHelperUtil:createDirectory(CfgPatcher.writePath)
                local patch_file = CfgPatcher.writePath .. tostring(md5) .. '.p'
                if io.exists(patch_file) then
                    CfgPatcher.run_patch(patch_file, md5)
                else
                    CfgPatcher.download_patch(patch_url, patch_file, md5)
                end
            end

         

        end
    end

  
end

function CfgPatcher.download_patch(url, file, md5)
     -- print("======================download_patch")

    local request = uf_netManager:createHTTPRequestGet(url, function(event) 

        local request = event.request
        local errorCode = request:getErrorCode()
        local response = request:getResponseString()
        local crypto = require("framework.crypto")  
        if errorCode == 0 then
           if CfgPatcher.check_md5 == false or crypto.md5(response, false) == md5 then
               io.writefile(file, response)
               CfgPatcher.run_patch(file, md5)

           end
        end
       
    end)
    request:start()

end


function CfgPatcher.run_patch(file, md5)
   -- print("======================run_patch " .. file)

    local content = io.readfile(file)
    if content then
        local crypto = require("framework.crypto")  
        if CfgPatcher.check_md5 == false  or crypto.md5(content, false) == md5 then
            local src = crypto.decodeBase64(content)
            -- local deflatelua = require("app.storage.deflatelua")
            -- local string_char = string.char
            -- local result = ""
            -- deflatelua.inflate_zlib({input=src,output=function(b) 
            --   result = result.. string_char(b) 
            -- end })

            local customFunc  = require("app.MyApp").oldloadstring(src)
            if customFunc ~= nil and type(customFunc) == "function" then
                 customFunc() 

            end  
        end
    end

end


return CfgPatcher
