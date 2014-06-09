{
	"version": "1.0.3",
	"previewer": "../ass/preview.jpg",
	"workerUrl": {
		"curve": "/tb/static-common/htmlfilter/worker/curveworker.js",
		"blend": "/tb/static-common/htmlfilter/worker/blendworker.js",
		"saturation": "/tb/static-common/htmlfilter/worker/saturationworker.js",
		"sharpen": "/tb/static-common/htmlfilter/worker/sharpenworker.js",
		"fugu": "/tb/static-common/htmlfilter/worker/fuguworker.js"
	},
	"filters": [{
		"name": "lomo",
		"filesData": {
			"amp": {
				"type": "amp",
				"url": "../filters/resource/lomopath.txt"
			},
			"png": {
				"type": "image",
				"url": "../filters/resource/lomopathlayer.jpg"
			}
		},
		"filterStep": [{
			"worker": "curve",
			"data": "amp"
		},
		{
			"worker": "blend",
			"data": "png",
			"options": {
				"mode": "multiply"
			}
		}]
	},
	{
		"name": "\u521D\u590F",
		"filesData": {
			"amaro": {
				"type": "amp",
				"url": "../filters/resource/amaro.txt"
			},
			"amarolayer": {
				"type": "image",
				"url": "../filters/resource/amarolayer.png"
			},
			"amarolayer2": {
				"type": "image",
				"url": "../filters/resource/amarolayer2.png"
			}
		},
		"filterStep": [{
			"worker": "curve",
			"data": "amaro"
		},
		{
			"worker": "blend",
			"data": "amarolayer",
			"options": {
				"mode": "colorBurn",
				"opacity": "0.6"
			}
		},
		{
			"worker": "blend",
			"data": "amarolayer2",
			"options": {
				"mode": "overlay",
				"opacity": "0.2"
			}
		}]
	},
	{
		"name": "\u79CB\u8272",
		"filesData": {
			"amp": {
				"type": "amp",
				"url": "../filters/resource/autumn.txt"
			}
		},
		"filterStep": [{
			"worker": "curve",
			"data": "amp"
		}]
	},
	{
		"name": "\u53E4\u5821",
		"filesData": {
			"amp": {
				"type": "amp",
				"url": "../filters/resource/castle.txt"
			},
			"castlelayer1": {
				"type": "image",
				"url": "../filters/resource/castlelayer1.png"
			},
			"castlelayer2": {
				"type": "image",
				"url": "../filters/resource/castlelayer2.png"
			}
		},
		"filterStep": [{
			"worker": "saturation",
			"options": {
				"r": "-50",
				"g": "-50",
				"b": "-50"
			}
		},
		{
			"worker": "curve",
			"data": "amp"
		},
		{
			"worker": "saturation",
			"options": {
				"r": "-25",
				"g": "-25",
				"b": "-25"
			}
		},
		{
			"worker": "blend",
			"data": "castlelayer1",
			"options": {
				"mode": "multiply"
			}
		},
		{
			"worker": "blend",
			"data": "castlelayer2",
			"options": {
				"mode": "overlay"
			}
		}]
	},
	{
		"name": "\u65F6\u5149",
		"filesData": {
			"amp": {
				"type": "amp",
				"url": "../filters/resource/shiguang.txt"
			},
			"shiguanglayer1": {
				"type": "image",
				"url": "../filters/resource/shiguanglayer1.png"
			},
			"shiguanglayer2": {
				"type": "image",
				"url": "../filters/resource/shiguanglayer2.png"
			}
		},
		"filterStep": [{
			"worker": "saturation",
			"options": {
				"r": "-25",
				"g": "-25",
				"b": "-25"
			}
		},
		{
			"worker": "curve",
			"data": "amp"
		},
		{
			"worker": "blend",
			"data": "shiguanglayer1",
			"options": {
				"mode": "softLight",
				"opacity": "0.8"
			}
		},
		{
			"worker": "blend",
			"data": "shiguanglayer2",
			"options": {
				"mode": "darken"
			}
		}]
	},
	{
		"name": "\u590D\u53E4",
		"filesData": {
			"amp": {
				"type": "amp",
				"url": "../filters/resource/nashiv.txt"
			}
		},
		"filterStep": [{
			"worker": "curve",
			"data": "amp"
		},
		{
			"worker": "fugu"
		}]
	},
	{
		"name": "HDR",
		"filesData": {
			"amp": {
				"type": "amp",
				"url": "../filters/resource/HDR.txt"
			}
		},
		"filterStep": [{
			"worker": "sharpen",
			"options": {
				"depth": "1"
			}
		},
		{
			"worker": "curve",
			"data": "amp"
		}]
	},
	{
		"name": "\u7ECF\u5178HDR",
		"filesData": {
			"amp": {
				"type": "amp",
				"url": "../filters/resource/mofangjingdianHDR.txt"
			}
		},
		"filterStep": [{
			"worker": "sharpen",
			"options": {
				"depth": "1"
			}
		},
		{
			"worker": "curve",
			"data": "amp"
		}]
	},
	{
		"name": "\u56DE\u5FC6",
		"filesData": {
			"memory": {
				"type": "amp",
				"url": "../filters/resource/memory.txt"
			},
			"memorylayer1": {
				"type": "image",
				"url": "../filters/resource/memorylayer1.png"
			}
		},
		"filterStep": [{
			"worker": "saturation",
			"options": {
				"r": "-50",
				"g": "-50",
				"b": "-50"
			}
		},
		{
			"worker": "curve",
			"data": "memory"
		},
		{
			"worker": "blend",
			"data": "memorylayer1",
			"options": {
				"mode": "multiply"
			}
		}]
	},
	{
		"name": "\u9ED1\u767D",
		"filesData": {
			"ansel": {
				"type": "amp",
				"url": "../filters/resource/ansel.txt"
			},
			"ansellayer": {
				"type": "image",
				"url": "../filters/resource/ansellayer.png"
			}
		},
		"filterStep": [{
			"worker": "saturation",
			"options": {
				"r": "-100",
				"g": "-100",
				"b": "-100"
			}
		},
		{
			"worker": "curve",
			"data": "ansel"
		},
		{
			"worker": "blend",
			"data": "ansellayer",
			"options": {
				"mode": "multiply"
			}
		}]
	},
	{
		"name": "\u7CD6\u6C34\u7247",
		"filesData": {
			"dreamy": {
				"type": "amp",
				"url": "../filters/resource/dreamy.txt"
			}
		},
		"filterStep": [{
			"worker": "curve",
			"data": "dreamy"
		}]
	},
	{
		"name": "\u6D41\u5E74",
		"filesData": {
			"jiushiguang": {
				"type": "amp",
				"url": "../filters/resource/jiushiguang.txt"
			},
			"jiushiguanglayer": {
				"type": "image",
				"url": "../filters/resource/jiushiguanglayer.png"
			},
			"jiushiguanglayer2": {
				"type": "image",
				"url": "../filters/resource/jiushiguanglayer2.png"
			}
		},
		"filterStep": [{
			"worker": "saturation",
			"options": {
				"r": "-20",
				"g": "-20",
				"b": "-20"
			}
		},
		{
			"worker": "curve",
			"data": "jiushiguang"
		},
		{
			"worker": "blend",
			"data": "jiushiguanglayer",
			"options": {
				"mode": "linearBurn",
				"opacity": "0.75"
			}
		},
		{
			"worker": "blend",
			"data": "jiushiguanglayer2",
			"options": {
				"mode": "overlay",
				"opacity": "0.1"
			}
		}]
	},
	{
		"name": "\u84DD\u8C03",
		"filesData": {
			"bluetone": {
				"type": "amp",
				"url": "../filters/resource/bluetone.txt"
			}
		},
		"filterStep": [{
			"worker": "curve",
			"data": "bluetone"
		}]
	},
	{
		"name": "\u70AB\u5F69",
		"filesData": {
			"xuancailomo": {
				"type": "amp",
				"url": "../filters/resource/xuancailomo.txt"
			},
			"xuancailayer": {
				"type": "image",
				"url": "../filters/resource/xuancailayer.png"
			},
			"xuancailayer2": {
				"type": "image",
				"url": "../filters/resource/xuancailayer2.png"
			}
		},
		"filterStep": [{
			"worker": "curve",
			"data": "xuancailomo"
		},
		{
			"worker": "blend",
			"data": "xuancailayer",
			"options": {
				"mode": "linearBurn",
				"opacity": "0.6"
			}
		},
		{
			"worker": "blend",
			"data": "xuancailayer2",
			"options": {
				"mode": "softLight"
			}
		}]
	},
	{
		"name": "\u6CB9\u753B",
		"filesData": {
			"youhua": {
				"type": "amp",
				"url": "../filters/resource/youhua.txt"
			},
			"youhualayer1": {
				"type": "image",
				"url": "../filters/resource/youhualayer1.png"
			},
			"youhualayercover": {
				"type": "image",
				"url": "../filters/resource/youhualayercover.png"
			}
		},
		"filterStep": [{
			"worker": "saturation",
			"options": {
				"r": "-25",
				"g": "-25",
				"b": "-25"
			}
		},
		{
			"worker": "curve",
			"data": "youhua"
		},
		{
			"worker": "blend",
			"data": "youhualayer1",
			"options": {
				"mode": "softLight"
			}
		},
		{
			"worker": "blend",
			"data": "youhualayercover",
			"options": {
				"mode": "normal"
			}
		}]
	},
	{
		"name": "\u9633\u5149",
		"filesData": {
			"amp": {
				"type": "amp",
				"url": "../filters/resource/sunny.txt"
			},
			"sunny": {
				"type": "image",
				"url": "../filters/resource/sunny.jpg",
				"extrude": "file"
			},
			"texture_frame": {
				"type": "image",
				"url": "../filters/resource/texture_frame.png"
			}
		},
		"filterStep": [{
			"worker": "blend",
			"data": "sunny",
			"options": {
				"mode": "screen",
				"scaleMode" : "inside"
			}
		},
		{
			"worker": "curve",
			"data": "amp"
		}]
	},
	{
		"name": "\u661F\u5149",
		"filesData": {
			"xinguang": {
				"type": "amp",
				"url": "../filters/resource/xinguang.txt"
			},
			"xinguanglayer": {
				"type": "image",
				"url": "../filters/resource/xinguanglayer.png",
				"extrude": "image"
			}
		},
		"filterStep": [{
			"worker": "saturation",
			"options": {
				"r": "-30",
				"g": "-30",
				"b": "-30"
			}
		},
		{
			"worker": "curve",
			"data": "xinguang"
		},
		{
			"worker": "blend",
			"data": "xinguanglayer",
			"options": {
				"mode": "screen",
				"scaleMode" : "outside"
			}
		}]
	}
	]
}