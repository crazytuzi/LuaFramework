command = classGc(function(self, _type)
    self.type = _type
    self.data = nil
end)
command.isCommand=true

-- function command.getName(self)
--     return self.__cname
-- end
function command.getType(self)
    return self.type
end
function command.setType(self,_type)
    self.type = _type
end
function command.getData(self)
    return self.data
end
function command.setData(self, data)
    self.data = data
end