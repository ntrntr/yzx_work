package yzx
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import away3d.animators.AnimatorBase;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.VertexAnimationSet;
	import away3d.animators.data.JointPose;
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.FirstPersonController;
	import away3d.core.base.Object3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.extrusions.Elevation;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.Filter3DBase;
	import away3d.library.assets.AssetType;
	import away3d.lights.DirectionalLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.loaders.parsers.DAEParser;
	import away3d.loaders.parsers.Max3DSParser;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.SimpleWaterNormalMethod;
	import away3d.materials.methods.TerrainDiffuseMethod;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	[SWF(width="1600", height="900",backgroundColor="#000000", frameRate="30", quality="LOW")]
	public class handTest2  extends Sprite
	{				
	
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var cameraController:FirstPersonController;
		private var awayStats:AwayStats;
		
		//light objects
		private var sunLight:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		
		//scene objects
		private var text:TextField;
		
		//rotation variables
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		//movement variables
		private var drag:Number = 0.5 * 1.5;
		private var walkIncrement:Number = 2;
		private var strafeIncrement:Number = 2;
		private var walkSpeed:Number = 0;
		private var strafeSpeed:Number = 0;
		private var walkAcceleration:Number = 0;
		private var strafeAcceleration:Number = 0;
		
		//scene objects
		private var _loaderGun:Loader3D;
		private var _loaderHand:Loader3D;
//		private var _loadBaofeng:Loader3D;
		
		
		//dae test
		
		[Embed(source="/../embeds/DAE/w_qbu10.png")]
		public static var QbuTexture:Class;
		
		//solider ant model
		[Embed(source="/../embeds/DAE/PlayerSkin_10.DAE",mimeType="application/octet-stream")]
		public static var PllayerSkin:Class;
		
		//solider ant model
		[Embed(source="/../embeds/DAE/w_p1_10.DAE",mimeType="application/octet-stream")]
		public static var P1:Class;
		
		//
		//[Embed(source="/../embeds/DAE/baofeng.DAE",mimeType="application/octet-stream")]
		[Embed(source="/../embeds/DAE/ak12gun.DAE",mimeType="application/octet-stream")]
		public static var BAOFENG:Class;
		
		
		//dae parser
		private var daeParserGun:DAEParser;
		private var daeParserHandle:DAEParser;
		private var daeBaofeng:DAEParser;
		
		//gun animation variables
		private var gunSkeletonAnimator:SkeletonAnimator;
		private var gunSkeletonAnimationSet:SkeletonAnimationSet;
		private var stateTransition:CrossfadeTransition = new CrossfadeTransition(0.5);
		private var gunMesh:Mesh;
		private var gunmaterial:TextureMaterial;
		
		//gun animation variables
		private var handSkeletonAnimator:SkeletonAnimator;
		private var handSkeletonAnimationSet:SkeletonAnimationSet;
		private var stateTransition1:CrossfadeTransition = new CrossfadeTransition(0.5);
		private var _meshHand:Mesh;
		private var handmaterial:TextureMaterial;
		
		//gun animation variables
		private var baofengSkeletonAnimator:SkeletonAnimator;
		private var baofengSkeletonAnimationSet:SkeletonAnimationSet;
		private var stateTransition2:CrossfadeTransition = new CrossfadeTransition(0.5);
		private var _baofengMesh:Mesh;
		private var baofengMaterial:TextureMaterial;
		
		public function handTest2()
		{
			init();
		}
		
		/**
		 * Global initialise function
		 */
		private function init():void
		{
			
			
			initEngine();
			initText();
			initLights();
			initMaterials();
			initObjects();
			
			//setup the scene
			_loaderGun = new Loader3D();
			_loaderGun.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteGun);
			_loaderGun.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onGunResourceComplete, false, 0, true);
			//_loaderGun.loadData(new P1(), null, null, new Max3DSParser(false));
			//_loaderGun.loadData(new P1(), null, null, new DAEParser(1));
			//_loaderGun.loadData(new PllayerSkin(), null, null, new DAEParser(1));
			//_loaderGun.parent.rotationX.
			
			//view.scene.addChild(_loaderGun);
			//trace(_loaderGun.name);
			
			
			_loaderHand = new Loader3D();
			_loaderHand.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteHand);
			_loaderHand.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onHanderResourceComplete, false, 0, true);
			//_loaderHand.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteHand);
			//_loader.loadData(new AntModel(), assetLoaderContext, null, new Max3DSParser(false));
			//_loaderGun.loadData(new PllayerSkin(), assetLoaderContext, null, new DAEParser(1));
			daeParserHandle = new DAEParser(1);
			//daeParserHandle.materials
			_loaderHand.loadData(new PllayerSkin(), null, null, daeParserHandle);
			
			//_loaderHand.x 
			//_loaderHand.loadData(new P1(), null, null, new DAEParser(1));
			//_loaderHand.loadData(new PllayerSkin(), null, null, new DAEParser(1));
			//_loaderHand
			//_loaderHand.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onModelLoadSuccess);
			//view.scene.addChild(_loaderHand);
			
//			_loadBaofeng = new Loader3D();
//			_loadBaofeng.scale(10);
//			_loadBaofeng.z = -600;
//			_loadBaofeng.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteBaofeng);
//			_loadBaofeng.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onBaofengResourceComplete, false, 0, true);
//			daeBaofeng = new DAEParser(1);
			//_loadBaofeng.loadData(new BAOFENG(), null, null, daeBaofeng);
			//view.scene.addChild(_loadBaofeng);
			initListeners();
		}
		
//		protected function onBaofengResourceComplete(e:LoaderEvent):void
//		{
//			// TODO Auto-generated method stub
//			_baofengMesh.material = baofengMaterial;
//			_baofengMesh.animator = baofengSkeletonAnimator;
//			
//			//			//add dynamic eyes
//			//			addHeroEye();
//			//			
//			var loader3d:Loader3D = e.target as Loader3D;
//			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteGun);
//			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onGunResourceComplete);
//			//			
//			//			_view.scene.addChild(_hero);
//			//			_view.scene.addChild(_gun);
//			baofengSkeletonAnimator.playbackSpeed = 1;
//			baofengSkeletonAnimator.play("null", stateTransition2);
//			//_baofengMesh.scale(10);
//			//_baofengMesh.z = -300;
//			//view.scene.addChild(_baofengMesh);
//		}
//		
//		protected function onAssetCompleteBaofeng(event:AssetEvent):void
//		{
//			// TODO Auto-generated method stub
//			if (event.asset.assetType == AssetType.MESH) {
//				var mesh:Mesh = event.asset as Mesh;
//				mesh.castsShadows = true;
//				_baofengMesh = mesh;
//				trace("_baofengMesh.name", (event.asset as Mesh).name);
//			} else if (event.asset.assetType == AssetType.MATERIAL) {
//				var material:TextureMaterial = event.asset as TextureMaterial;
//				//material.shadowMethod = new FilteredShadowMapMethod(_light);
//				material.lightPicker = lightPicker;
//				material.gloss = 30;
//				material.specular = 1;
//				material.ambientColor = 0x303040;
//				material.ambient = 1;
//				baofengMaterial = material;
//				trace("baofeng material.name", material.name);
//			}
//			else if(event.asset.assetType == AssetType.SKELETON)
//			{
//				trace("baofeng Skeleton.name", (event.asset as Skeleton).name);
//				//create a new skeleton animation set
//				baofengSkeletonAnimationSet = new SkeletonAnimationSet(4);
//				
//				//wrap our skeleton animation set in an animator object and add our sequence objects
//				baofengSkeletonAnimator = new SkeletonAnimator(baofengSkeletonAnimationSet, event.asset as Skeleton, false);
//				
//				//apply our animator to our mesh
//				//gunMesh.animator = skeletonAnimator;
//			}
//			else if(event.asset.assetType == AssetType.ANIMATION_NODE)
//			{
//				//create animation objects for each animation node encountered
//				var animationNode:SkeletonClipNode = event.asset as SkeletonClipNode;
//				trace("SkeletonClipNode.name", animationNode.name);
//				baofengSkeletonAnimationSet.addAnimation(animationNode);
//				trace("animationNode.name", animationNode.name);
//				
//			}
//			else if(event.asset.assetType == AssetType.ANIMATOR)
//			{
//				trace("animator.name", (event.asset as AnimatorBase).name);
//			}
//			else if(event.asset.assetType == AssetType.CONTAINER)
//			{
//				//				trace("ObjectContainer3D.name", (event.asset as ObjectContainer3D).name);
//				//				if((event.asset as ObjectContainer3D).parent != null)
//				//				{
//				//					trace("parent ObjectContainer3D.name", (event.asset as ObjectContainer3D).parent.name);
//				//				}
//				var tmpObjectContainer3D:ObjectContainer3D = event.asset as ObjectContainer3D;
//				//tmpObjectContainer3D.
//				if(tmpObjectContainer3D.name == "node-Bip01_R_Hand")
//				{
//					trace("found!, numChildren", tmpObjectContainer3D.numChildren);
//					var test:Object3D = new Object3D();
//					
//				}
//			}
//			
//		}
		
		protected function onHanderResourceComplete(e:LoaderEvent):void
		{
			_meshHand.material = handmaterial;
			_meshHand.position = new Vector3D(0,0,0,1);
			// TODO Auto-generated method stub
			//handSkeletonAnimator.useCondensedIndices = true;
			_meshHand.animator = handSkeletonAnimator;
			//_meshHand.
			//_meshHand.animator.useCondensedIndices = true;
			//_meshHand.animator = gunSkeletonAnimator;
			
			
			var loader3d:Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteHand);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onHanderResourceComplete);
			
			_meshHand.scale(10);
			_meshHand.z = -100;
			//_meshHand.addChild(gunMesh);
			//_meshHand.addChild(_baofengMesh);
			view.scene.addChild(_meshHand);
			//handSkeletonAnimator.playbackSpeed = 1;
			handSkeletonAnimator.play("null", stateTransition1);
			//handSkeletonAnimator.play("null");
		}
		
		protected function onGunResourceComplete(e:LoaderEvent):void
		{
			// TODO Auto-generated method stub
			//apply our animator to our mesh
			//gunMesh.material = gunmaterial;
			gunMesh.material = gunmaterial;
			gunMesh.animator = gunSkeletonAnimator;
			
			//			//add dynamic eyes
			//			addHeroEye();
			//			
			var loader3d:Loader3D = e.target as Loader3D;
			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteGun);
			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onGunResourceComplete);
			//			
			//			_view.scene.addChild(_hero);
			//			_view.scene.addChild(_gun);
			gunSkeletonAnimator.playbackSpeed = 1;
			gunSkeletonAnimator.play("null", stateTransition);
			//gunMesh.scale(10);
			//gunMesh.z = -200;
			//view.scene.addChild(gunMesh);
		}
		
		//		protected function onModelLoadSuccess(event:LoaderEvent):void
		//		{
		//			// TODO Auto-generated method stub
		//			//copy from https://as3snip.wordpress.com/2011/12/29/the-most-basic-away3d-example-with-collada-and-animation/
		//			var loader3d:Loader3D = event.target as Loader3D;
		//			loader3d.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetCompleteHand);
		//			loader3d.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onModelLoadSuccess);
		//			var obj:ObjectContainer3D = event.target as ObjectContainer3D;
		//			//daeParserHandle.
		//			trace("obj.numChildren",obj.numChildren);
		//			trace("obj.name",obj.name);
		////			for each(var mesh:Mesh in _meshHand)
		////			{
		////				trace("mesh.x ",mesh.x);
		////				mesh.x = 50;
		////			}
		//		}
		
		/**
		 * Listener function for asset complete event on loader
		 */
		private function onAssetCompleteGun(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				mesh.castsShadows = true;
				gunMesh = mesh;
				trace("mesh.name", (event.asset as Mesh).name);
			} else if (event.asset.assetType == AssetType.MATERIAL) {
				var material:TextureMaterial = event.asset as TextureMaterial;
				//material.shadowMethod = new FilteredShadowMapMethod(_light);
				material.lightPicker = lightPicker;
				material.gloss = 30;
				material.specular = 1;
				material.ambientColor = 0x303040;
				material.ambient = 1;
				gunmaterial = material;
				trace("material.name", material.name);
			}
			else if(event.asset.assetType == AssetType.SKELETON)
			{
				trace("Skeleton.name", (event.asset as Skeleton).name);
				//create a new skeleton animation set
				gunSkeletonAnimationSet = new SkeletonAnimationSet(3);
				
				//wrap our skeleton animation set in an animator object and add our sequence objects
				gunSkeletonAnimator = new SkeletonAnimator(gunSkeletonAnimationSet, event.asset as Skeleton, false);
				
				//apply our animator to our mesh
				//gunMesh.animator = skeletonAnimator;
			}
			else if(event.asset.assetType == AssetType.ANIMATION_NODE)
			{
				//create animation objects for each animation node encountered
				var animationNode:SkeletonClipNode = event.asset as SkeletonClipNode;
				gunSkeletonAnimationSet.addAnimation(animationNode);
				trace("gunSkeletonClipNode.name", animationNode.name);
				
			}
			else if(event.asset.assetType == AssetType.ANIMATOR)
			{
				trace("animator.name", (event.asset as AnimatorBase).name);
			}
			else if(event.asset.assetType == AssetType.CONTAINER)
			{
				//				trace("ObjectContainer3D.name", (event.asset as ObjectContainer3D).name);
				//				if((event.asset as ObjectContainer3D).parent != null)
				//				{
				//					trace("parent ObjectContainer3D.name", (event.asset as ObjectContainer3D).parent.name);
				//				}
				var tmpObjectContainer3D:ObjectContainer3D = event.asset as ObjectContainer3D;
				//tmpObjectContainer3D.
				if(tmpObjectContainer3D.name == "node-Bip01_R_Hand")
				{
					trace("found!, numChildren", tmpObjectContainer3D.numChildren);
					var test:Object3D = new Object3D();
					
				}
			}
		}
		
		/**
		 * Listener function for asset complete event on loader
		 */
		private function onAssetCompleteHand(event:AssetEvent):void
		{
			if (event.asset.assetType == AssetType.MESH) {
				var mesh:Mesh = event.asset as Mesh;
				mesh.castsShadows = true;
				//if(mesh.name == "PlayerSkin")
				//{
				_meshHand = mesh;
				//}			
				trace("hand _meshHand.name", mesh.name, mesh.id);
				//_meshHand.x = 200;
			} else if (event.asset.assetType == AssetType.MATERIAL) {
				var material1:TextureMaterial = event.asset as TextureMaterial;
				//material.shadowMethod = new FilteredShadowMapMethod(_light);
				material1.lightPicker = lightPicker;
				material1.gloss = 30;
				material1.specular = 1;
				material1.ambientColor = 0x303040;
				material1.ambient = 1;
				handmaterial = material1;
				trace("hand material.name", material1.name, material1.id);
			}
			else if(event.asset.assetType == AssetType.ANIMATION_SET)
			{
				//animationSet = event.asset as SkeletonAnimationSet;
				var tmp:SkeletonAnimationSet = event.asset as SkeletonAnimationSet;
				trace("hand SkeletonAnimationSet", tmp.name);
			}
			else if(event.asset.assetType == AssetType.SKELETON)
			{
				var skeleton1:Skeleton = event.asset as Skeleton;
				trace("hand skeleton.name", skeleton1.name, skeleton1.id);
				handSkeletonAnimationSet = new SkeletonAnimationSet(3);
				handSkeletonAnimator = new SkeletonAnimator(handSkeletonAnimationSet, skeleton1, false);
			}
			else if(event.asset.assetType == AssetType.ANIMATION_NODE)
			{
				//create animation objects for each animation node encountered
				var animationNode1:SkeletonClipNode = event.asset as SkeletonClipNode;
				handSkeletonAnimationSet.addAnimation(animationNode1);
				trace("hand SkeletonClipNode.name", animationNode1.name);
			}
			else if(event.asset.assetType == AssetType.ANIMATOR)
			{
				trace("hand animator.name", (event.asset as AnimatorBase).name);
			}
			else if(event.asset.assetType == AssetType.CONTAINER)
			{
				//				trace("ObjectContainer3D.name", (event.asset as ObjectContainer3D).name);
				//				if((event.asset as ObjectContainer3D).parent != null)
				//				{
				//					trace("parent ObjectContainer3D.name", (event.asset as ObjectContainer3D).parent.name);
				//				}
				var tmpObjectContainer3D:ObjectContainer3D = event.asset as ObjectContainer3D;
				//tmpObjectContainer3D.
				if(tmpObjectContainer3D.name == "node-Bip01_R_Hand")
				{
					trace("found!, numChildren", tmpObjectContainer3D.numChildren);
					var test:Object3D = new Object3D();
					
				}
			}
			
			
		}
		
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			view = new View3D();
			scene = view.scene;
			camera = view.camera;
			
			camera.lens.far = 4000;
			camera.lens.near = 1;
			camera.y = 300;
			
			//setup controller to be used on the camera
			cameraController = new FirstPersonController(camera, 180, 0, -80, 80);
			
			view.addSourceURL("srcview/index.html");
			addChild(view);
			
			view.filters3d = Vector.<Filter3DBase>[ new BloomFilter3D(200, 200, .85, 15, 2) ];
			
			awayStats = new AwayStats(view);
			addChild(awayStats);
		}
		
		/**
		 * Create an instructions overlay
		 */
		private function initText():void
		{
			text = new TextField();
			text.defaultTextFormat = new TextFormat("Verdana", 11, 0xFFFFFF);
			text.width = 240;
			text.height = 100;
			text.selectable = false;
			text.mouseEnabled = false;
			text.text = "Mouse click and drag - rotate\n" + 
				"Cursor keys / WSAD - move\n";
			
			text.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			
			addChild(text);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			sunLight = new DirectionalLight(-300, -300, -5000);
			sunLight.color = 0xfffdc5;
			sunLight.ambient = 1;
			scene.addChild(sunLight);
			
			lightPicker = new StaticLightPicker([sunLight]);
			
		}
		
		/**
		 * Initialise the material
		 */
		private function initMaterials():void
		{
		}
		
		
		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{

		}
		
		/**
		 * Initialise the listeners
		 */
		private function initListeners():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			onResize();
		}
		
		/**
		 * Navigation and render loop
		 */
		private function onEnterFrame(event:Event):void
		{
			
			//			if(handSkeletonAnimator && handSkeletonAnimator.globalPose.numJointPoses >= 10)
			//			{
			//				gunMesh.transform = handSkeletonAnimator.globalPose.jointPoses[10].toMatrix3D();
			//				_baofengMesh.transform = handSkeletonAnimator.globalPose.jointPoses[10].toMatrix3D();
			//			}
			
			if (move) {
				cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
				cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
				
			}
			
			if (walkSpeed || walkAcceleration) {
				walkSpeed = (walkSpeed + walkAcceleration)*drag;
				if (Math.abs(walkSpeed) < 0.01)
					walkSpeed = 0;
				cameraController.incrementWalk(walkSpeed);
			}
			
			if (strafeSpeed || strafeAcceleration) {
				strafeSpeed = (strafeSpeed + strafeAcceleration)*drag;
				if (Math.abs(strafeSpeed) < 0.01)
					strafeSpeed = 0;
				cameraController.incrementStrafe(strafeSpeed);
			}
			
			view.render();
		}
		
		/**
		 * Key down listener for camera control
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
					walkAcceleration = walkIncrement;
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					walkAcceleration = -walkIncrement;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					strafeAcceleration = -strafeIncrement;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					strafeAcceleration = strafeIncrement;
					break;
			}
		}
		
		/**
		 * Key up listener for camera control
		 */
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.DOWN:
				case Keyboard.S:
					walkAcceleration = 0;
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.RIGHT:
				case Keyboard.D:
					strafeAcceleration = 0;
					break;
			}
		}
		
		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
		{
			move = true;
			lastPanAngle = cameraController.panAngle;
			lastTiltAngle = cameraController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseUp(event:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * Mouse stage leave listener for navigation
		 */
		private function onStageMouseLeave(event:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			awayStats.x = stage.stageWidth - awayStats.width;
		}
	}
}