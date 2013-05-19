local function SetStatus(self, new_status)
	local attr = self:GetAttribute()

	if attr.Status == new_status then
		return
	end
	attr.Status = new_status
	RadioButton_UpdateIcon(self)
end

function RadioButton_SetText(self, new_text)
	local attr = self:GetAttribute()

	if attr.Text == new_text then
		return
	end
	attr.Text = new_text

	local obj = self:GetControlObject("text")
	obj:SetText(new_text)
end


function RadioButton_GetText(self)
	local attr = self:GetAttribute()
	return attr.Text
end


function RadioButton_SetSelect(self, is_select)
	local attr = self:GetAttribute()

	if attr.Select == is_select then
		return
	end
	attr.Select = is_select
	RadioButton_UpdateIcon(self)
end


function RadioButton_GetSelect(self)
	local attr = self:GetAttribute()
	return attr.Select
end

function RadioButton_GetMinSize( self )
	local text = self:GetControlObject( "text" )
	local cx, cy = text:GetTextExtent()
	local attr = self:GetAttribute()
	local left, top, right, bottom = self:GetObjPos()
	return cx + attr.TextPos, bottom - top
end


function RadioButton_UpdateIcon(self)
	local attr = self:GetAttribute()
	local objBox = self:GetControlObject("box")
	local objDot = self:GetControlObject("dot")
	if attr.Status == 1 then
		objBox:SetResID(attr.BoxNormalIconID)
		objDot:SetResID(attr.DotNormalIconID)
	elseif attr.Status == 2 then
		objBox:SetResID(attr.BoxHoverIconID)
		objDot:SetResID(attr.DotNormalIconID)
	elseif attr.Status == 3 then
		objBox:SetResID(attr.BoxNormalIconID)
		objDot:SetResID(attr.DotNormalIconID)
	elseif attr.Status == 4 then
		objBox:SetResID(attr.BoxDisableIconID)
		objDot:SetResID(attr.DotDisableIconID)
	end
	
	if attr.Select then
		objDot:SetVisible(true)
	else
		objDot:SetVisible(false)
	end
end



function RadioButton_OnBind(self)
	local attr = self:GetAttribute()
	
	RadioButton_OnVisibleChange(self, self:GetVisible())

	local obj = self:GetControlObject("text")
	obj:SetText(attr.Text)
	RadioButton_UpdateIcon(self)
end


function RadioButton_OnLButtonDown(self)
	local attr = self:GetAttribute()
	local status = attr.Status
	if status ~= 4 and status ~= 3 then
		SetStatus(self,3)
	end

	return 0, false
end

function RadioButton_OnLButtonUp(self)
	local attr = self:GetAttribute()
	local status = attr.Status
	if status ~= 4 then
	    if status ~= 2 then
		    SetStatus(self,2)
		end
		
		self:FireExtEvent("OnRadioButtonClick")
	end
	
	return 0, false
end

function RadioButton_OnChar(self, char)
    if char == 32 or char == 13 then
        local attr = self:GetAttribute()
        self:FireExtEvent("OnRadioButtonClick")
    elseif char == 9 then
        self:RouteToFather()
    end
    return 0, false
end

function RadioButton_OnMouseMove(self)
	local attr = self:GetAttribute()
	local status = attr.Status
	local objDot = self:GetControlObject("dot")
	if status ~= 4 and status ~= 2 then
		if attr.Select == true then
		    if attr.MouseLeaveAniPos ~= nil then
		        attr.MouseLeaveAniPos:Stop()
				attr.MouseLeaveAniPos = nil
		    end
		    
			if attr.MouseMoveAniPos == nil then
				local left,top,right,bottom = objDot:GetObjPos()
				attr.curLeft,attr.curTop,attr.curRight,attr.curBottom = (left+right)/2,(top+bottom)/2,(left+right)/2,(top+bottom)/2
			else
				attr.MouseMoveAniPos:Stop()
				attr.MouseMoveAniPos = nil
				local left,top,right,bottom = objDot:GetObjPos()
				attr.curLeft,attr.curTop,attr.curRight,attr.curBottom = left,top,right,bottom
			end
			
			SetStatus(self,2)
			local ownerTree = self:GetOwner()
			local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")	
			local posAniTemplate = templateManager:GetTemplate("radiobutton.showani","AnimationTemplate")
			local instance = posAniTemplate:CreateInstance()
			if instance then
				instance:SetKeyFrameRect(attr.curLeft,attr.curTop,attr.curRight,attr.curBottom,attr.initLeft,attr.initTop,attr.initRight,attr.initBottom)
				instance:BindLayoutObj(objDot)
				ownerTree:AddAnimation(instance)
				instance:Resume()
				attr.MouseMoveAniPos = instance
			end
		else
			SetStatus(self,2)
		end
	end
	return 0, false
end

function RadioButton_OnMouseLeave(self)
	local attr = self:GetAttribute()
	local status = attr.Status
	local objDot = self:GetControlObject("dot")
	if status ~= 4 and status ~= 1 then
		if attr.Select == true then
		    if attr.MouseMoveAniPos ~= nil then
		        attr.MouseMoveAniPos:Stop()
				attr.MouseMoveAniPos = nil
		    end
		    
			if attr.MouseLeaveAniPos == nil then
			    local left,top,right,bottom = objDot:GetObjPos()
				attr.curLeft,attr.curTop,attr.curRight,attr.curBottom = left,top,right,bottom
			else
				attr.MouseLeaveAniPos:Stop()
				attr.MouseLeaveAniPos = nil
				local left,top,right,bottom = objDot:GetObjPos()
				attr.curLeft,attr.curTop,attr.curRight,attr.curBottom = left,top,right,bottom
			end
			
			SetStatus(self,1)
			local ownerTree = self:GetOwner()
			local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")	
			local posAniTemplate = templateManager:GetTemplate("radiobutton.showani","AnimationTemplate")
			local instance = posAniTemplate:CreateInstance()
			if instance then
				instance:SetKeyFrameRect(attr.curLeft,attr.curTop,attr.curRight,attr.curBottom,attr.initLeft,attr.initTop,attr.initRight,attr.initBottom)
				instance:BindLayoutObj(objDot)
				ownerTree:AddAnimation(instance)
				instance:Resume()
				attr.MouseLeaveAniPos = instance
			end
		else
			SetStatus(self,1)
		end
	end
	return 0, false
end


function RadioButton_OnPosChange(self)
	--get current position of contrl
	local ctrl_left, ctrl_top, ctrl_right, ctrl_bottom = self:GetObjPos()
	local ctrl_width = ctrl_right - ctrl_left
	local ctrl_height = ctrl_bottom - ctrl_top

	--move box object
	local objBox = self:GetControlObject("box")
	local left, top, right, bottom = objBox:GetObjPos()
	local box_width = right - left
	local box_height = bottom - top

	local box_left = 0
	local box_top = (ctrl_height - box_height) / 2
	objBox:SetObjPos(box_left, box_top, box_left + box_width, box_top + box_height)

	--move text object
	local text_left = box_left + box_width + 5
	local text_top = 0

	local textObj = self:GetControlObject("text")
	textObj:SetObjPos(text_left, text_top, ctrl_width, ctrl_height)
end

function RadioButton_OnFocusChange(self, focus)
	--local focusrect = self:GetControlObject("focusrectangle")
	--focusrect:SetVisible(focus)
	local text = self:GetControlObject("text")
	local attr = self:GetAttribute()
	if text == "" or text == nil then
		attr.ShowFocusRect = false
	end
	local focusrect = self:GetControlObject("focusrectangle")
	if not attr.ShowFocusRect then
		focusrect:SetVisible(false)
	else
		local text = self:GetControlObject("text")
		local l, t, r, b = text:GetObjPos()
		local w, h = text:GetTextExtent()
		focusrect:SetObjPos(l - 16, t, l + w + 2, b)
		focusrect:SetVisible(focus)
	end
end


--================================================================================
function AddRadioButton(self, button_id, text, left, top, width, height)
	local attr = self:GetAttribute()
	
	local obj = self:GetControlObject(button_id)
	if obj ~= nil then
		return -1
	end

	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local newItem = objFactory:CreateUIObject(button_id, "Thunder.RadioButton")
	local itemAttr = newItem:GetAttribute()
	itemAttr.Text = text
	itemAttr.BitmapID = attr.BitmapID
	itemAttr.Visible = true
	itemAttr.ShowFocusRect = false
	
	local item_count = self:GetChildCount()
	if (attr.SelectedButtonID ~= "" and attr.SelectedButtonID == button_id) or
		(attr.SelectedButtonID == "" and item_count == 0) then
		itemAttr.Select = true
		attr.SelectedButtonID = button_id
	else
		itemAttr.Select = false
	end

	local function OnRadioButtonClick(button, event_name)	
		local id = button:GetID()
		self:SetSelectByID(id)
	end

	newItem:AttachListener("OnRadioButtonClick", true, OnRadioButtonClick)
	self:AddChild(newItem)

	newItem:SetObjPos(left, top, left + width, top + height)
	return 0
end

function AddCustomRadioButton(self, obj, left, top, width, height)	
	if obj == nil then
		return -1
	end

	local attr = self:GetAttribute()
	local itemAttr = obj:GetAttribute()
	itemAttr.BitmapID = attr.BitmapID
	itemAttr.Visible = true
	
	local item_count = self:GetChildCount()
	if (attr.SelectedButtonID ~= "" and attr.SelectedButtonID == obj:GetID()) or
		(attr.SelectedButtonID == "" and item_count == 0) then
		itemAttr.Select = true
		attr.SelectedButtonID = obj:GetID()
	else
		itemAttr.Select = false
	end

	local function OnRadioButtonClick(button, event_name)	
		local id = button:GetID()
		self:SetSelectByID(id)
	end

	obj:AttachListener("OnRadioButtonClick", true, OnRadioButtonClick)
	self:AddChild(obj)

	obj:SetObjPos(left, top, left + width, top + height)
	return 0
end

function GetRadioButton(self, button_id)
	local obj = self:GetControlObject(button_id)
	return obj
end

function SetSelectByID(self, button_id)
	local attr = self:GetAttribute()
	if attr.SelectedButtonID == button_id then
		return
	end
	
	local newSelectedObj = self:GetControlObject(button_id)
	if newSelectedObj == nil then
		return
	end

	if attr.SelectedButtonID ~= nil then
		local obj = self:GetControlObject(attr.SelectedButtonID)
		if obj ~= nil then
			obj:SetSelect(false)
		end
	end

	attr.SelectedButtonID = button_id

	newSelectedObj:SetSelect(true)
	self:FireExtEvent("OnButtonSelectedChanged")
end


function SetSelectByIndex(self, index)
	local item_count = self:GetChildCount()
	if index > item_count then
		return
	end
	
	local newSelectedObj = self:GetChildByIndex(index)
	local newSelectedID = newSelectedObj:GetID()

	local attr = self:GetAttribute()
	if attr.SelectedButtonID == newSelectedID then
		return
	end

	if attr.SelectedButtonID ~= nil then
		local obj = self:GetControlObject(attr.SelectedButtonID)
		if obj ~= nil then
			obj:SetSelect(false)
		end
	end

	attr.SelectedButtonID = button_id

	newSelectedObj:SetSelect(true)
end


function GetSelectedButtonID(self)	
	local attr = self:GetAttribute()
	return attr.SelectedButtonID
end


function OnBind(self)
	local attr = self:GetAttribute()
	if attr.Visible ~= nil then
		if attr.Visible == true then
			attr.Visible = false
			self:SetVisible(true)
		else
			attr.Visible = true
			self:SetVisible(false)
		end
	end
end


function OnInitControl(self)
	local attr = self:GetAttribute()
	local objText = self:GetControlObject("text")
	if attr.Font ~= nil then
		objText:SetTextFontResID( attr.Font )
	end
	if attr.TextColor ~= nil then
		objText:SetTextColorResID( attr.TextColor )
	end
	local left, top, right, bottom = self:GetObjPos()
	objText:SetObjPos( attr.TextPos, 0, right - left, bottom - top )
	local objDot = self:GetControlObject("dot")
	local left,top,right,bottom = objDot:GetObjPos()
	attr.initLeft,attr.initTop,attr.initRight,attr.initBottom = left,top,right,bottom
end

function Container_OnBind(self)
	local attr = self:GetAttribute()
	if attr.Visible ~= nil then
		if attr.Visible == true then
			attr.Visible = false
			self:SetVisible(true)
		else
			attr.Visible = true
			self:SetVisible(false)
		end
	end
end

function RadioButton_OnEnableChange(self, enable)
	local attr = self:GetAttribute()

	local objText = self:GetControlObject("text")
	if enable then
		SetStatus(self,1)
		objText:SetTextColorResID(attr.TextColor)

	else
		SetStatus(self,4)
		objText:SetTextColorResID(attr.DisableTextColor)
	end
end

function RadioButton_OnVisibleChange(self, visible)
	-- self:SetVisible(visible)
	self:SetChildrenVisible(visible)
end

function Container_OnVisibleChange(self, visible)
	local item_count = self:GetChildCount()

	for i = 1, item_count do
		local obj = self:GetChildByIndex(i - 1)
		obj:SetVisible(visible)
	end
end