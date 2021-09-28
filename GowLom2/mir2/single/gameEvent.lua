local gameEvent = {}

cc.GameObject.extend(gameEvent):addComponent("components.behavior.EventProtocol"):exportMethods()

gameEvent.skillHotKey = "skill_hot_key"

return gameEvent
