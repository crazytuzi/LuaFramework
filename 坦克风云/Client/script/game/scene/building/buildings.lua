buildings={
    allBuildings={}
}

function buildings:tick()

    for k,v in pairs(self.allBuildings) do
         v:tick()
    end
end

function buildings:upgrade(id,changeImg)
    self.allBuildings[id]:show(self.allBuildings[id].parent,changeImg)
end

function buildings:removeBuild(id)
    self.allBuildings[id]:show(self.allBuildings[id].parent,true)

end

function buildings:getAllBuildingSp()
    return self.allBuildings
end

function buildings:getBuildingSpByBid(id)
    return self.allBuildings[id].buildSp
end

function buildings:dispose()
    self.allBuildings={}
end
