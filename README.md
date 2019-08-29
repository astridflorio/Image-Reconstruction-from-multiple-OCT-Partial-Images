# Image Reconstruction from multiple OCT Partial Images
**Optical coherence tomography** (**OCT**) is an optical imaging method. It can be considered analogous to ultrasound imaging with greater resolution but lower penetration depth.

However, OCT cannot penetrate the tooth fully to observe tooth decay in-between teeth, since this area cannot be accessed directly, unlike with X-rays. 
 
 
This project attempts to reconstruct a **3D image of a tooth from partial 2D images** taken from the side of a tooth which are normally accessible. Various techniques were explored both in terms of image capture and image registration.

## Contents:

### Code:

- **_composePath.m_** : function used to automatically compose path to load OCT image stack generated by scanner
- **_loadOCT.m_** : main function used to load image stacks
- **_preliminary.m_** : script used to manipulate preliminary images provided by Dr Tomlins (Queen Mary, SMD)
- **_reload_script.m_** : script used to reload images into Matlab
- **_saveAsPNGstack.m_** : save volume to PNG stack
- **_yStack.m_** : script used to manipulate _y-stack_ images
- **_loadRotatingOCT.m_** : function used to load _z-stack_ images (modified from code kindly provided by Dr Tomlins)

### Images used: 

Contains images captured using other techniques used for comparison in the project:
1. _**DiagnoCAM results.docx**_ : contains images captured using KaVo DiagnoCAM (see __Sections 2.3.2 and 3.5.1__)
2. _**x1ba_XMT_png.zip**_ : contains the image captured using micro-CT as an image stack which can also be loaded using _reload_script.m_ (see __Sections 2.3.1.1 and 3.5.2__)
3. ___X1ba.docx___ : x ray images of tooth _X1ba_ (see __Sections 2.3.1 and 3.5.2__).

### Results: manipulated images obtained

- *4-1-1_Results* : results as described in __Section 4.1.1__
- *4-1-3_Results* : results as described in __Section 4.1.3__
- *4-1-3_Results* : (proximal)results as described in __Section 4.1.3__ including proximal view
- *4-3_Registered* : results as described in __Section 4.3__
- *4-2_thetaStack* : results as described in __Section 4.2__
- *4-2_thetaStack_90* : results with 90 degrees angle as described in __Section 4.2__
- *4-2_thetaStack_120* : results with 120 degrees angle as described in __Section 4.2__
- *4-2_thetaStack_150* : results with 150 degrees angle as described in __Section 4.2__

#### Unprocessed Images
- *preliminary* : preliminary images used in __Section 4.1__
- *theta_stack* : theta stack used in __Section 4.2__
- *y_stack* : y stack used in __Section 4.3__

	For access to the images, please contact the author.
