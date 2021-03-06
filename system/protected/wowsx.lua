-- ProbablyEngine Rotations
-- Released under modified BSD, see attached LICENSE.

-- Functions that require OffSpring

local L = ProbablyEngine.locale.get

function ProbablyEngine.protected.WoWSX()
    if WOWSX_ISLOADED then
      
        _G['objectTypes'] = {
          Object = 1,
          Item = 2,
          Container = 3,
          Unit = 4,
          Player = 5,
          GameObject = 6,
          DynamicObject = 7,
          Corpse = 8,
          AreaTrigger = 9,
          SceneObject = 10
        }
      
        function Cast(spell, target)
          if type(spell) == "number" then
            CastSpellByID(spell, target)
          else
            CastSpellByName(spell, target)
          end
        end
        
        function CastGround(spell, target)
            if UnitExists(target) then
              Cast(spell, target)
              CastAtPosition(ObjectPosition(UnitGUID(target)))
              CancelPendingSpell()
              return
            end
            if not ProbablyEngine.timeout.check('groundCast') then
                ProbablyEngine.timeout.set('groundCast', 0.05, function()
                    Cast(spell)
                    if IsAoEPending() then
                        SetCVar("deselectOnClick", "0")
                        CameraOrSelectOrMoveStart(1)
                        CameraOrSelectOrMoveStop(1)
                        SetCVar("deselectOnClick", "1")
                        SetCVar("deselectOnClick", stickyValue)
                        CancelPendingSpell()
                    end
                end)
            end
        end
        
        function Macro(text)
          return RunMacroText(text)
        end
        
        function UseItem(name, target)
          return UseItemByName(name, target)
        end
        
        function Distance(a, b)
            if UnitExists(a) and UnitIsVisible(a) and UnitExists(b) and UnitIsVisible(b) then
                local ax, ay, az = ObjectPosition(UnitGUID(a))
                local bx, by, bz = ObjectPosition(UnitGUID(b))
                return math.sqrt(((bx-ax)^2) + ((by-ay)^2) + ((bz-az)^2)) -- ((UnitCombatReach(a)) + (UnitCombatReach(b)))
            end
            return 0
        end
        
        function IterateObjects(callback, objectType)
            local totalObjects = GetNumObjects()
            for i = 1, totalObjects do
                local object = GetObjectGuid(i)
                if objectType and ObjectType(object) == objectType then
                    callback(object)
                else
                    callback(object)
                end
            end
        end
        
        local uau_cache_time = { }
        local uau_cache_count = { }
        local uau_cache_dura = 0.1
        function UnitsAroundUnit(unit, distance, ignoreCombat)
            local uau_cache_time_c = uau_cache_time[unit..distance..tostring(ignoreCombat)]
            if uau_cache_time_c and ((uau_cache_time_c + uau_cache_dura) > GetTime()) then
                return uau_cache_count[unit..distance..tostring(ignoreCombat)]
            end
            if UnitExists(unit) then
                local total = 0
                local totalObjects = GetNumObjects()
                for i = 1, totalObjects do
                    local object = GetObjectGuid(i)
                    local oType = ObjectType(object)
                    if oType == objectTypes.Unit then
                        local reaction = UnitReaction("player", object)
                        local combat = UnitAffectingCombat(object)
                        if reaction and reaction <= 4 and (ignoreCombat or combat) then
                            if Distance(object, unit) <= distance then
                                total = total + 1
                            end
                        end
                    end
                end
                uau_cache_count[unit..distance..tostring(ignoreCombat)] = total
                uau_cache_time[unit..distance..tostring(ignoreCombat)] = GetTime()
                return total
            else
                return 0
            end
        end
        
        function FriendlyUnitsAroundUnit(unit, distance, ignoreCombat)
            local uau_cache_time_c = uau_cache_time[unit..distance..tostring(ignoreCombat)..'f']
            if uau_cache_time_c and ((uau_cache_time_c + uau_cache_dura) > GetTime()) then
                return uau_cache_count[unit..distance..tostring(ignoreCombat)..'f']
            end
            if UnitExists(unit) then
                local total = 0
                local totalObjects = GetNumObjects()
                for i = 1, totalObjects do
                    local object = GetObjectGuid(i)
                    local oType = ObjectType(object)
                    if oType == objectTypes.Unit then
                        local reaction = UnitReaction("player", object)
                        local combat = UnitAffectingCombat(object)
                        if reaction and reaction >= 5 and (ignoreCombat or combat) then
                            if Distance(object, unit) <= distance then
                                total = total + 1
                            end
                        end
                    end
                end
                uau_cache_count[unit..distance..tostring(ignoreCombat)..'f'] = total
                uau_cache_time[unit..distance..tostring(ignoreCombat)..'f'] = GetTime()
                return total
            else
                return 0
            end
        end
        
        function ObjectFromUnitID(unit)
            return UnitGUID(unit)
        end

        local losFlags =  bit.bor(TRACELINE_FLAGS_LINEOFSIGHT)
        function LineOfSight(a, b)
            local ax, ay, az = ObjectPosition(UnitGUID(a))
            local bx, by, bz = ObjectPosition(UnitGUID(b))
            if Traceline(ax, ay, az+2.25, bx, by, bz+2.25, losFlags) then
                return false
            end
            return true
        end

        ProbablyEngine.protected.unlocked = true
        ProbablyEngine.protected.method = "wowsx"
        ProbablyEngine.timer.unregister('detectUnlock')
        ProbablyEngine.timer.unregister('detectWoWSX')
        ProbablyEngine.print(L('unlock_wowsx'))

    end

end