ScenePathModel = ScenePathModel or BaseClass(BaseModel)

function ScenePathModel:__init()
    self.path_result = {}
    self.path_walked = {}
    self.path_data = {}
end

--路径深度优先遍历(无需担忧环路)
function ScenePathModel:pathing( from,to )
    print(string.format("from %s to %s ", from, to))
    if DataPath.data_cfg[from] == nil then
        return false
    end

    for i,v in ipairs(DataPath.data_cfg[from].candidate) do
        if table.containValue( self.path_walked, v[1])  then
            -- return false
        else
            table.insert( self.path_walked, v[1] )
            if v[1]~= to then
                -- print(v[1])
                if self:pathing( v[1],to )== false then
                    local index = 0
                    for _i,_v in ipairs(self.path_walked) do
                        if _v==v[1]then
                            index=_i
                        end
                    end
                    table.remove( self.path_walked,index )
                else
                    return true
                end
            elseif v[1]==to then
                -- print(v[1])
                return true
            end
        end
    end
    return false
end

--获取传送门ID
function ScenePathModel:getdoor( from,to )
    for i,v in ipairs(DataPath.data_cfg[from].candidate) do
        if v[1]==to then
            table.insert(self.path_result, v[2] )
            return
        end
    end
end


--外部调用寻路计算函数结果保存在   self.path_result(所要经过的传送门ID)    self.path_walked(起始到目的地图经过的地图ID)
function ScenePathModel:install_pathresult( from,to )
    self.path_walked = {}
    table.insert( self.path_walked, from )
    -- utils.dump(ScenePathModel.path_walked,"11111")
    self:pathing( from,to )
    self.path_result = {}
    for i=1,#self.path_walked-1 do
        local _F = self.path_walked[i]
        local _T = self.path_walked[i+1]
        self:getdoor( _F,_T )
    end
    -- BaseUtils.dump(ScenePathModel.path_result,"install_pathresult")
end

function ScenePathModel:get_path( from,to )
    local key = string.format( "%s_%s",from,to )
    local path = self.path_data[key]
    if path == nil then
        self:install_pathresult( from,to )
        path = self.path_result
    end
    return path
end