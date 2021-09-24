function model_bookmark(uid,data)
    local self = {
        uid = uid,
        info = {},
        updated_at = 0,
    }
  	
    -- private fields are implemented using locals
    -- they are faster than table access, and are truly private, so the code that uses your class can't get them
    -- local test = uid

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

        if type(self.info) ~= 'table' then
            self.info = {}
        end

        return true
    end

    function self.toArray(format)        
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' then              
                if format then
                    if type(v) == 'table'  then
                        if next(v) then data[k] = v end
                    elseif v ~= 0 and v~= '0' and v~='' then
                       data[k] = v
                end
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
    
    -- 标记
    function self.mark(recordType,recordName,mapId,mapx,mapy)
        if type(recordType) ~= "table" then
            recordType = {0}
        end

        local record = {}
        table.insert(record,recordName)
        table.insert(record,mapx)
        table.insert(record,mapy)
        table.insert(record,recordType)

        mapId = 'm'..mapId
        self.info[mapId] = record

        return true
    end

    function self.update(markinfo)        
        if type(markinfo) == 'table' then
          for k,v in pairs(markinfo) do
              if self.info[k] then
                  self.info[k] = v
              end
          end
          return true
        end
    end

    function self.delete(mapId)
        mapId = 'm' .. mapId 

        if self.info[mapId] then
            self.info[mapId] = nil
            return true
        end
    end

    -- return number
    function self.getBookmarkNum()
        return table.length(self.info)
    end

    function self.isMark()
        local max = 20
        return self.getBookmarkNum() < max
    end

    return self
end	

