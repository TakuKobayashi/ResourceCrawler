module Datapool::ThreedModelMetum
  THREED_MODEL_FILE_EXTENSIONS = [
    # http://edutechwiki.unige.ch/en/3D_file_format
    ".vrm",
    ".gltf",
    ".fbx",
    # 3D Studio Max
    ".3ds",
    ".max",
    # AC3D
    ".ac",
    # Apple 3DMF
    ".3dm",
    ".3dmf",
    # Autocad
    ".dwg",
    # Blender
    ".blend",
    # Caligari Object
    ".cob",
    # Collada
    ".dae",
    # Dassault
    ".3dxml",
    # DEC Object File Format
    ".off",
    # DirectX 3D Model
    ".x",
    # Drawing Interchange Format
    ".dxf",
    # DXF Extensible 3D
    # X3D Extensible 3D
    ".x3d",
    # Form-Z
    ".fmz",
    # GameExchange2-Mirai
    ".gof",
    # Google Earth
    ".kml",
    ".kmz",
    # HOOPS HSF
    ".hsf",
    # LightWave
    ".lwo",
    ".lws",
    # Lightwave Motion
    ".mot",
    # MicroStation
    ".dgn",
    # Nendo
    ".ndo",
    # OBJ
    # VideoScape
    # Wavefront
    ".obj",
    # Okino Transfer File Format
    ".bdf",
    # OpenFlight
    ".flt",
    # Openinventor
    ".iv",
    # Pro Engineer
    ".slp",
    # Radiosity
    ".radio",
    # Raw Faces
    ".raw",
    # RenderWare Object
    ".rwx",
    # Revit
    ".rvt",
    # Sketchup
    ".skp",
    # Softimage XSI
    ".xsi",
    # Stanford PLY
    ".ply",
    # STEP
    ".stp",
    # Stereo Litography
    ".stl",
    # Strata StudioPro
    ".vis",
    # TrueSpace
    ".scn",
    # Universal
    ".u3d",
    # VectorWorks
    ".mcd",
    # Viewpoint
    ".vet",
    # VRML
    ".wrl",
    # Wings 3D
    ".wings",
    # Xfig Export
    ".fig",
  ]

  def self.threed_model?(url)
    return THREED_MODEL_FILE_EXTENSIONS.any?{|ext| File.extname(url).downcase.start_with?(ext) }
  end
end