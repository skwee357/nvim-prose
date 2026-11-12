local Component = {}
Component.__index = Component

function Component:extend()
    local cls = setmetatable({}, { __index = self })
    cls.__index = cls
    cls.super = self
    return cls
end

function Component:init(options)
    self.options = options
end

function Component:new(options)
    local obj = setmetatable({}, self)
    obj:init(options)
    return obj
end

return Component
