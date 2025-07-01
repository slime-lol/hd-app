local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local gui = script.Parent
local mainFrame = gui.MainFrame
local controls = mainFrame.Controls

mainFrame.Visible = false

local function createSkyboxParts(viewport, camera)
	local sky = game.Lighting:FindFirstChildOfClass("Sky")
	if not sky then return end

	local size = 1024
	local halfSize = size / 2

	local faces = {
		{
			Name = "Front",
			Face = Enum.NormalId.Back,
			Texture = sky.SkyboxFt,
			Position = Vector3.new(0, 0, -halfSize),
			Rotation = Vector3.new(0, 0, 0),
		},
		{
			Name = "Back",
			Face = Enum.NormalId.Front,
			Texture = sky.SkyboxBk,
			Position = Vector3.new(0, 0, halfSize),
			Rotation = Vector3.new(0, math.rad(180), 0),
		},
		{
			Name = "Left",
			Face = Enum.NormalId.Right,
			Texture = sky.SkyboxLf,
			Position = Vector3.new(-halfSize, 0, 0),
			Rotation = Vector3.new(0, math.rad(-90), 0),
		},
		{
			Name = "Right",
			Face = Enum.NormalId.Left,
			Texture = sky.SkyboxRt,
			Position = Vector3.new(halfSize, 0, 0),
			Rotation = Vector3.new(0, math.rad(90), 0),
		},
		{
			Name = "Top",
			Face = Enum.NormalId.Bottom,
			Texture = sky.SkyboxUp,
			Position = Vector3.new(0, halfSize, 0),
			Rotation = Vector3.new(math.rad(-90), 0, 0),
		},
		{
			Name = "Bottom",
			Face = Enum.NormalId.Top,
			Texture = sky.SkyboxDn,
			Position = Vector3.new(0, -halfSize, 0),
			Rotation = Vector3.new(math.rad(90), 0, 0),
		},
	}

	for _, faceData in ipairs(faces) do
		local part = Instance.new("Part")
		part.Name = faceData.Name .. "Sky"
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(size, size, 1)
		part.Transparency = 1
		part.Parent = viewport

		local cf = camera.CFrame * CFrame.new(faceData.Position) * CFrame.Angles(
			faceData.Rotation.X,
			faceData.Rotation.Y,
			faceData.Rotation.Z
		)
		part.CFrame = cf

		local decal = Instance.new("Decal")
		decal.Face = faceData.Face
		decal.Texture = faceData.Texture
		decal.Parent = part
	end
end

local originalCamera = workspace.CurrentCamera



function load(onLoadFinish)
	mainFrame.Visible = true
	mainFrame.Position = UDim2.new(0,0,0,0)
	for i = 1, 4 do
		local yScale = math.random(10, 100) / 100
		local bar = controls["Bar" .. i]
		local text = controls["Text" .. i]

		bar.Point4.Position = UDim2.new(-0.5, 0, yScale, 0)
		text.Text = 100 - string.format("%.0f", yScale * 100)
	end


	local viewport = mainFrame.Disc



	local function cloneAppearance(character, viewport)
		local cloneModel = Instance.new("Model")
		cloneModel.Name = character.Name .. "_Clone"

		cloneModel.Parent = workspace

		for _, part in pairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				local partClone = part:Clone()
				partClone.Parent = cloneModel
			end
		end

		local originalShirt = character:FindFirstChildOfClass("Shirt")
		if originalShirt then
			local shirtClone = Instance.new("Shirt")
			shirtClone.ShirtTemplate = originalShirt.ShirtTemplate
			shirtClone.Parent = cloneModel
		end

		local originalPants = character:FindFirstChildOfClass("Pants")
		if originalPants then
			local pantsClone = Instance.new("Pants")
			pantsClone.PantsTemplate = originalPants.PantsTemplate
			pantsClone.Parent = cloneModel
		end

		for _, accessory in pairs(character:GetChildren()) do
			if accessory:IsA("Accessory") then
				local accessoryClone = accessory:Clone()
				accessoryClone.Parent = cloneModel
			end
		end

		local originalHumanoid = character:FindFirstChildOfClass("Humanoid")
		if originalHumanoid then
			local humanoidClone = originalHumanoid:Clone()
			humanoidClone.Parent = cloneModel

			local humanoidDesc = originalHumanoid:GetAppliedDescription()
			humanoidClone:ApplyDescription(humanoidDesc)
		end

		if cloneModel:FindFirstChild("HumanoidRootPart") then
			cloneModel.PrimaryPart = cloneModel.HumanoidRootPart
		end

		cloneModel.Parent = viewport

		return cloneModel
	end





	for _, obj in pairs(workspace:GetChildren()) do
		if obj:IsA("Terrain") then
			-- do nothing (no need to add anything here)
		elseif obj:IsA("Model") then
			if obj:FindFirstChild("Humanoid") then
				local appearanceClone = cloneAppearance(obj)
				appearanceClone.Parent = viewport
			else
				local modelClone = obj:Clone()
				modelClone.Parent = viewport
			end
		elseif obj:IsA("BasePart") then
			local partClone = obj:Clone()
			partClone.Parent = viewport
		end
	end
	local camera = workspace.CurrentCamera:Clone()
	camera.Parent = viewport


	mainFrame.Disc.CurrentCamera = mainFrame.Disc:FindFirstChild('Camera')
	createSkyboxParts(mainFrame.Disc, mainFrame.Disc.CurrentCamera)


	mainFrame.Disc.CurrentCamera = mainFrame.Disc:FindFirstChild("Camera")
	mainFrame.Disc.Position= UDim2.new(.3,0,.5,0)
	mainFrame.Disc.Size = UDim2.new(.8,0,.8,0)
	tweenService:Create(mainFrame.Disc, TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Size = UDim2.new(.25,0,.25,0), Position = UDim2.new(.225,0,.5,0)}):Play()
	mainFrame.DiamondTip.ZIndex = 5
	task.wait(1.2)
	tweenService:Create(mainFrame.Disc, TweenInfo.new(12, Enum.EasingStyle.Linear), {Rotation = mainFrame.Disc.Rotation + (360 * 60)}):Play()
	onLoadFinish()
	for i=0, 9, 1 do
		if i % 5 == 0 then
			script.Parent.Loading:Play()
		end
		local originalPos = mainFrame.Disc.Position
		local targetPos = UDim2.new(
			originalPos.X.Scale - 0.6,
			originalPos.X.Offset - 0,
			originalPos.Y.Scale - 0.5,
			originalPos.Y.Offset - 0
		)

		tweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, true), {Position = targetPos}):Play()
		tweenService:Create(mainFrame.DiamondTip, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In, 0, true), {Rotation = 50}):Play()
		for i = 1, 4 do
			local yPos = -0.05 + math.random(0, 90) / 100
			local bar = controls["Bar" .. i]
			local text = controls["Text" .. i]
			print(i .. ": " .. yPos)

			local newPos = UDim2.new(-0.5, 0, yPos, 0)

			tweenService:Create(bar.Point4, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = newPos}):Play()

			text.Text = 100 - string.format("%.0f", yPos * 100)
		end
		task.wait(0.99)
	end	
	local targetResizeSize = UDim2.new(.8,0,.8,0)
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(.5,0)
	uiCorner.Parent = viewport
	tweenService:Create(mainFrame, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Position = UDim2.new(2,0,0,0)}):Play()
	task.wait(1)
	mainFrame.Visible = false
	viewport:ClearAllChildren()
	
	workspace.CurrentCamera = originalCamera

end

print("Character added")
task.wait(2)

workspace.ClickPart.ClickDetector.MouseClick:Connect(function(player)
	load(
		function()
			player.Character.PrimaryPart.CFrame = workspace.OtherPart.CFrame + Vector3.new(5,5,5)
		end
	)
end)

