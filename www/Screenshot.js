/*
 *  This code is adapted from the work of Michael Nachbaur
 *  by Simon Madine of The Angry Robot Zombie Factory
 *   - Converted to Cordova 1.6.1 by Josemando Sobral.
 *   - Converted to Cordova 2.0.0 by Simon MacDonald
 *  2012-07-03
 *   - Enhanced with resize/crop mode and path/format support by Jam Zhang & Anthony Zhu
 *  2016-12-01
 *  MIT licensed
 */
var exec = require('cordova/exec'), formats = ['png','jpg'];
module.exports = {
	save:function(callback,options) {
		
		options.format = (options.format || 'png').toLowerCase();
		options.filename = options.filename || 'screenshot_'+Math.round((+(new Date()) + Math.random()));
		if(formats.indexOf(options.format) === -1){
			return callback && callback(new Error('invalid format '+options.format));
		}

		options.quality = typeof(options.quality) !== 'number'?100:options.quality;
		
		options.cropTop = parseInt(options.cropTop);
		options.cropBottom = parseInt(options.cropBottom);
		options.cropLeft = parseInt(options.cropLeft);
		options.cropRight = parseInt(options.cropRight);
		if (isNaN(options.cropTop)) options.cropTop = 0;
		if (isNaN(options.cropBottom)) options.cropBottom = 0;
		if (isNaN(options.cropLeft)) options.cropLeft = 0;
		if (isNaN(options.cropRight)) options.cropRight = 0;
		
		exec(function(res){
			callback && callback(null,res);
		}, function(error){
			callback && callback(error);
		}, "Screenshot", "saveScreenshot", 
		[options.format, 
		options.quality, 
		options.path,
		options.filename, 
		options.width, 
		options.height, 
		options.mode, 
		options.cropTop, 
		options.cropBottom, 
		options.cropLeft, 
		options.cropRight]);
	},

	URI:function(callback, quality){
		quality = typeof(quality) !== 'number'?100:quality;
		exec(function(res){
			callback && callback(null, res);
		}, function(error){
			callback && callback(error);
		}, "Screenshot", "getScreenshotAsURI", [quality]);

	}
};
