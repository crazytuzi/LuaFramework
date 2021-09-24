function model_bag(uid,data)
    local platform = getConfig('base.AppPlatform')
    local self = {
        uid = uid,
        info = platform == 'zsy_ru' and {p19=2,p20=1,p21=1,p31=1,p1030=1,p45=1} or platform == 'qihoo' and {p19=2,p20=1,p21=1,p31=1,p1079=1,p45=1} or {p19=2,p20=1,p21=1,p31=1,p45=1},
        updated_at = 0,
    }
	
  -- private fields are implemented using locals
  -- they are faster than table access, and are truly private, so the code that uses your class can't get them
  -- local test = uid

    local meta = {
            __index = function(tb, key)
                    return rawget(tb,tostring(key)) or rawget(tb,'p'..key) or 0
            end 
    }

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end
        
        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end

        return true
    end

    function self.toArray(format)
        local data = {}
            for k,v in pairs (self) do
                if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                    if format then
                        -- if type(v) == 'table'  then
                        --     if next(v) then data[k] = v end
                        -- elseif v ~= 0 and v~= '0' and v~='' then
                            data[k] = v
                        --end
                    else
                        data[k] = v
                    end
                end
            end

        return data
    end

   function self.getKeys()
      local data = {}
      for k,v in pairs (self) do
	      if type(v)~="function" then
		      table.insert(data,k)
	      end
        end
        return data
    end
    
    function self.add(pid,nums)
        nums = math.floor(tonumber(nums) or 0)
        
        if nums > 0 and type(self.info)== 'table' then
             -- 配置文件
            local cfg = getConfig('prop.' .. pid) 

            local iMaxCount = tonumber(cfg.maxCount)
            local iCurrCount = tonumber(self.info[pid]) or 0
            local iAllCount = nums + iCurrCount

            if (iAllCount) < iMaxCount then               
                  self.info[pid] = iAllCount
            else
                  self.info[pid] = iMaxCount
            end

            regKfkLogs(self.uid,'item',{
                    item_id=pid,
                    item_op_cnt=nums,
                    item_before_op_cnt=iCurrCount,
                    item_after_op_cnt=self.info[pid],
                    item_pos='背包',
                    flags={'item_id'},
                    merge={'item_op_cnt'},
                    rewrite={'item_after_op_cnt'},
                    addition={
                    },
                }
            )

            recordRequest(self.uid,pid,{num=nums})

            return true
        end
    end

    function self.use(pid,nums)
        if type(self.info) == 'table' and self.info[pid] then            
            local n = (tonumber(self.info[pid]) or 0) - tonumber(nums)

            if n >= 0 then
                local item_before_op_cnt = self.info[pid]                
                regKfkLogs(self.uid,'item',{
                        item_id=pid,
                        item_before_op_cnt=item_before_op_cnt,
                        item_op_cnt=-nums,
                        item_after_op_cnt=n,
                        item_pos='背包',
                        flags={'item_id'},
                        merge={'item_op_cnt'},
                        rewrite={'item_after_op_cnt'},
                        addition={
                        }
                    }
                ) 
            end

            recordRequest(self.uid,pid,{num=nums})  

            if n > 0 then          
                self.info[tostring(pid)] = n             
                return true
            elseif n == 0 then
                self.info[tostring(pid)] = nil
                return true
            end 
        end  

        return false
    end

    -- 使用更多的道具
    function self.usemore(data)
        local flag = true
        if type (data)=='table' and next(data) then
            for k,v in pairs(data) do
               local ret=self.use(k,v)
               if not ret then
                    flag=false
                    break
               end
            end
        end
        return flag
    end

    function self.getPropNums(pid)        
        return type(self.info) == 'table' and self.info[pid] or 0
    end

    setmetatable(self.info, meta)

    return self
end	
