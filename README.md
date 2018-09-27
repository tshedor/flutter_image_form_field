# ImageFormField

Handle image uploads in a Flutter `Form`.

## Usage

In order to fully customize the photo upload field, several callbacks and classes are required. In most cases, you will be mixing photos from a remote source and a local upload. For these, an adapter layer is useful:

```dart
class ImageInputAdapter {
  /// Initialize from either a URL or a file, but not both.
  ImageInputAdapter({
    this.file,
    this.url
  }) : assert(file != null || url != null), assert(file != null && url == null), assert(file == null && url != null);

  /// An image file
  final File file;
  /// A direct link to the remote image
  final String url;

  /// Render the image from a file or from a remote source.
  Widget widgetize() {
    if (file != null) {
      return Image.file(file);
    } else {
      return FadeInImage(
        image: NetworkImage(url),
        placeholder: AssetImage("assets/images/placeholder.png"),
        fit: BoxFit.contain,
      );
    }
  }
}
```

Finally, in a Flutter `Form`:

```dart
import 'package:image_form_field/image_form_field.dart';

ImageFormField<ImageInputAdapter>(
  previewImageBuilder: (_, ImageInputAdapter image) =>
    image.widgetize(),
  buttonBuilder: (_, int count) =>
    Container(
      child: Text(
        count == null || count < 1 ? "Upload Image" : "Upload More"
      )
    )
  initializeFileAsImage: (File file) =>
    ImageInputAdapter(file: file),
  initialValue: existingPhotoUrl == null ? null : (List<ImageInputImageAdapter>()..add(ImageInputImageAdapter(url: existingPhotoUrl))),
  // Even if `shouldAllowMultiple` is true, images will always be a `List` of the declared type (i.e. `ImageInputAdater`).
  onSaved: (images) _images = images,
)
```

For a full example that includes uploading an image, see [example/lib/main.dart](example/lib/main.dart).

## Parameters

(T == declared display type, i.e. `ImageFormField<T>`)

| name | type | required | description |
|---|---|---|---|
| `previewImageBuilder` | Widget Function(BuildContext, T) | * | How the image is rendered below the upload button |
| `buttonBuilder` | Widget Function(BuildContext, [int]) | * | The display of the button. **Do not use `FlatButton`**; the button is already wrapped in a `GestureRecognizer` |
| `initializeFileAsImage` | T Function(File) | * | Convert an upload to the adapter class |
| `controller` | ImageFieldController | | Direct access to the images currently displayed or uploaded |
| `initialValue` | List<T> | | Images displayed on initial render; if `initialValue` is set in `initState` or by some other non-pass through method, **do not render the field until the value is set**. |
| `onSaved` | VoidCallback Function(List<T>) | | Handle the uploaded/remote images when the form is saved |
| `validator` | VoidCallback Function(List<T>) | | Handle the uploaded/remote images when the form is validated |
| `errorTextStyle` | TextStyle | | Control how text display when field is invalid; often it's best to use `Theme.of(context).inputDecorationTheme.errorStyle` |
| `autoValidate` | bool | | If field should autovalidate (defaults to false) |
| `shouldAllowMultiple` | bool | | If field permits more than one image upload (defaults to true) |

## Thanks

Props to [AllGo](https://www.canweallgo.com/) for providing the initial support for this project.
