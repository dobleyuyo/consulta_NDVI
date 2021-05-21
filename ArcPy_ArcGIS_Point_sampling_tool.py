######################
### carga de ArcPy ###
######################
import archook
archook.locate_arcgis()
archook.get_arcpy()
import arcpy
from arcpy.sa import *
arcpy.SignInToPortal_server("","", "") # usuario, clave
arcpy.CheckOutExtension('Spatial') 

# Otras librerias necesarias
import os
import glob


########################################
### Selección de carpetas y archivos ###
########################################

# Definir la ubicación del shape de puntos ; el shape con la grilla ; el nuevo shape con la consulta
shape_puntos="C:\\Pablo QGIS\\Arrabio\\shapes\\puntos pescados 1.shp"
shape_grilla="C:\\Pablo QGIS\\Arrabio\\shapes\\pixeles pescados 1.shp"
shape_consulta="C:\\Pablo QGIS\\Arrabio\\shapes\\consulta PixelPescado 2015_2016.shp"

# carpeta donde se encuentran los rasters
carpeta_rasters="C:\\Pablo QGIS\\ADECO\\campos\\imagenes\\H12 V11\\2015-2016\\raster escalado"



#################
### Funciones ###
#################

def point_sampling_tool(shape_puntos,shape_grilla,shape_consulta,carpeta_rasters):
    #####################################################
    ### Creacion del shape de puntos para la consulta ###
    #####################################################

    # Selecciono los campos de la grilla que contienen las clases de ambiente
    field_DB = arcpy.FieldMappings() 
    field_DB.addTable(shape_grilla)

    # Función de la consulta : Spatial Join
    arcpy.SpatialJoin_analysis(shape_puntos,shape_grilla,shape_consulta,"#","#",field_DB)

    #limpio la base de datos del nuevo shape, para quedarme sólo con el ID y la Clase.
    lista_campos_consulta = arcpy.ListFields(shape_consulta)
    consulta_field_DB= arcpy.FieldMappings() 
    consulta_field_DB.addTable(shape_consulta)

    for field in lista_campos_consulta:
        campo_en_turno="{0}".format(field.name) # nombre del campo que evalua en cada iteración
        if campo_en_turno != "clase" and  campo_en_turno !="ID":  # comparación con los campos que me interesa conservar
             x=consulta_field_DB.findFieldMapIndex(campo_en_turno)
             if x>=0:
                 arcpy.DeleteField_management(shape_consulta,campo_en_turno)
    ##################################################
    ### Consulta espacial de los Rasters Escalados ###
    ##################################################

    # define el directorio que se usa
    os.chdir(carpeta_rasters)

    # lista con todos los rasters de la carpeta 
    lista_rasters=glob.glob("*.tif")

    # Consulta espacial con el shape de consulta y la lista de rasters
    ExtractMultiValuesToPoints(shape_consulta,lista_rasters)

    print("-------- Consulta espacial finalizada --------")

 
