// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.aloisdeniel.image_native_resizer;

import android.media.ExifInterface;
import android.util.Log;
import java.util.Arrays;
import java.util.List;

class ExifDataCopier {
  void copyExif(String filePathOri, String filePathDest) {
    try {
      ExifInterface oldExif = new ExifInterface(filePathOri);
      ExifInterface newExif = new ExifInterface(filePathDest);

      List<String> attributes =
          Arrays.asList(
              "FNumber",
              "ExposureTime",
              "ISOSpeedRatings",
              "GPSAltitude",
              "GPSAltitudeRef",
              "FocalLength",
              "GPSDateStamp",
              "WhiteBalance",
              "GPSProcessingMethod",
              "GPSTimeStamp",
              "DateTime",
              "DateTimeOriginal",
              "Flash",
              "GPSLatitude",
              "GPSLatitudeRef",
              "GPSLongitude",
              "GPSLongitudeRef",
              "Make",
              "Model",
              "Orientation");
      for (String attribute : attributes) {
        setIfNotNull(oldExif, newExif, attribute);
      }

      newExif.saveAttributes();

    } catch (Exception ex) {
      Log.e("ExifDataCopier", "Error preserving Exif data on selected image: " + ex);
    }
  }

  private static void setIfNotNull(ExifInterface oldExif, ExifInterface newExif, String property) {
    if (oldExif.getAttribute(property) != null) {
      newExif.setAttribute(property, oldExif.getAttribute(property));
    }
  }
}
