# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# MediaPipe - keep all proto/framework classes referenced by R8
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# Isar
-keep class dev.isar.** { *; }
-dontwarn dev.isar.**

# Google ML Kit / TFLite (used by camera/ml packages)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-keep class kotlinx.** { *; }
-dontwarn kotlinx.**

# Gson (used by some plugins)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# OkHttp (networking)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Suppress all other missing class warnings from generated rules
-ignorewarnings
