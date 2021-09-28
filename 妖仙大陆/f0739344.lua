local _M = { }
_M.__index = _M

local PetModel      = require 'Zeus.Model.Pet'
local Util          = require 'Zeus.Logic.Util'

function _M:onExit()
	
	if self.root ~= nil then
		self.root:RemoveFromParent(true)
		self.root = nil
	end
end

local function IsinList(dataList,id)
    for k,v in pairs(dataList) do
        if k == id then
            return k
        end
    end
    return nil
end

function _M.CreateAttUI(parent,petList)
	local ret = { }
    setmetatable(ret, _M)
    ret.root = XmdsUISystem.CreateFromFile("xmds_ui/pet/pet_att.gui.xml")
    if parent ~= nil then
        parent:AddChild(ret.root)
    end

    local cvs = ret.root:FindChildByEditName("cvs_att1", true)
    local tb_att = cvs:FindChildByEditName("tb_att",true)
    local tb_att2 = cvs:FindChildByEditName('tb_att2',true)

    local cvs2 = ret.root:FindChildByEditName("cvs_att2", true)
    local tb_att3 = cvs2:FindChildByEditName("tb_att",true)


    local attr = ""
    local attrList = {}
    local infoData = GlobalHooks.DB.Find('PetAssociate',{})


    local function func( rewardGrade )
        for m,n in pairs(petList) do
            if m == tonumber(rewardGrade[1]) then
                if n.upLevel >= tonumber(rewardGrade[2]) then
                    return true
                else
                    return false
                end
            end
        end
        return false
    end

    local function check(petIds)
        for i,v in pairs(petIds) do
            local  rewardGrade = string.split(v, ":")
            if not func(rewardGrade) then
                return false
            end
        end
        return true
    end

    for i,v in pairs(infoData) do
        local PetIDAttr = string.split(v.PetID,";")
        if check(PetIDAttr) then
            local addPro = string.split(v.AddPro,";")
            for m,n in pairs(addPro) do
                local addProAttr = string.split(n,":")
                local info  = IsinList(attrList,tonumber(addProAttr[1]))
                if info then
                    attrList[info] = attrList[info] + tonumber(addProAttr[2])
                else
                    attrList[tonumber(addProAttr[1])] = tonumber(addProAttr[2])
                end
            end
        end
    end


    for m,n in pairs(attrList) do
        local Data = GlobalHooks.DB.Find('Attribute',{ID = tonumber(m)})[1].attName
        attr = attr .. string.format("%s : %s",Data,n).."\n"
    end   
    tb_att3.Text = attr


    ret.root.Visible = false


    PetModel.getPetDataList(function( data )
    	local allatt = {}
    	local nameList = {}
    	for k,v in pairs(data) do
    		local masterdata = GlobalHooks.DB.Find('MasterProp',{PropID = k})[1]
    		if masterdata then
    			for i=1,4 do
    				if allatt[masterdata['Prop' .. i] ] == nil then
    					allatt[masterdata['Prop' .. i] ] = 0
    				end

                    local masterdataEx = GlobalHooks.DB.Find('MasterUpgradeProp',{PetID = k, UpLevel = v.upLevel})[1]
                    local value = allatt[masterdata['Prop' .. i] ] + math.floor( math.pow(masterdata['Grow' ..i ],v.level - 1)*masterdata['Min' .. i] + 0.5)
		    		
                    if masterdataEx then
                        value = value + masterdataEx['PetMin' ..i ]
                    end
                    
                    allatt[masterdata['Prop' .. i]] = value

                    local find = false
		    		for k=1,#nameList do
		    			if nameList[k] == masterdata['Prop' .. i] then
		    				find = true
		    				break
		    			end
		    		end
		    		if not find then
		    			table.insert(nameList,masterdata['Prop' .. i])
		    		end
		    	end
    		end
    	end

    	for i,v in ipairs(nameList) do
    		local name = tb_att:Clone()
    		local num = tb_att2:Clone()
    		local Y = tb_att.Y + i * tb_att.Height
    		name.Text = v .. ":"
    		num.Text = allatt[v]
    		name.Y = Y
    		num.Y = Y
    		cvs:AddChild(name)
    		cvs:AddChild(num)
    	end
    	ret.root.Visible = true
    end)
    return ret
end


return _M
