package com.aloisdeniel.image_native_resizer;

import androidx.annotation.NonNull;

import android.app.Activity;
import android.os.Environment;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.File;

/** ImageNativeResizerPlugin */
public class ImageNativeResizerPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private ImageResizer imageResizer;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "image_native_resizer");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // If a background flutter view tries to register the plugin, there will be no activity from the registrar,
      // we stop the registering process immediately because the ImagePicker requires an activity.
      return;
    }
    
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "image_native_resizer");
    final ImageNativeResizerPlugin plugin = new ImageNativeResizerPlugin();
    channel.setMethodCallHandler(plugin);
    Activity activity = registrar.activity();
    plugin.setup(activity);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("resize")) {
      final String imagePath = call.argument("imagePath");
      final Double maxWidth = call.argument("maxWidth");
      final Double maxHeight = call.argument("maxHeight");
      final Integer quality = call.argument("quality");
      final String resultPath = imageResizer.resizeImageIfNeeded(imagePath,maxWidth,maxHeight,quality);
    
      result.success(resultPath);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }


  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    setup(binding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    tearDown();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  private void setup(Activity setupActivity) {
    this.imageResizer = constructImageResizer(setupActivity);
  }

  private void tearDown() {
    this.imageResizer = null;
    channel.setMethodCallHandler(null);
    channel = null;
  }

  private final ImageResizer constructImageResizer(final Activity setupActivity) {
    final File externalFilesDirectory =
        setupActivity.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
    final ExifDataCopier exifDataCopier = new ExifDataCopier();
    return new ImageResizer(externalFilesDirectory, exifDataCopier);
  }
}
