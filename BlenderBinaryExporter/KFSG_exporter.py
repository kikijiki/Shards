import bpy
import struct

from io_utils import ExportHelper
from bpy.props import StringProperty, BoolProperty, EnumProperty
from array import array

class ExportKfsgModel(bpy.types.Operator, ExportHelper):

    bl_idname = "export.kfsg_model"
    bl_label = "Export KFSG model"

    filename_ext = ".kfsg"

    filter_glob = StringProperty(default="*.kfsg", options={'HIDDEN'})

    export_normals = BoolProperty(name="Normals", description="Export normals", default=True)
    export_uv = BoolProperty(name="UV", description="Export texture coordinates", default=True)

    mesh = bpy.context.active_object.data
    uvdata = mesh.uv_textures.active

    vbuf = array('f')
    nbuf = array('f')
    tbuf = array('f')
    ibuf = array('H')

    uvdic = {}

    @classmethod
    def poll(cls, context):
        return context.active_object != None

    def computeVertices(self):
        for v in self.mesh.vertices:
            self.vbuf.append(v.co.x)
            self.vbuf.append(v.co.y)
            self.vbuf.append(v.co.z)

            if self.export_normals == True:
                self.nbuf.append(v.normal.x)
                self.nbuf.append(v.normal.y)
                self.nbuf.append(v.normal.z)

            if self.export_uv == True:
                self.tbuf.append(self.uvdic[v.index][0]);
                self.tbuf.append(self.uvdic[v.index][1]);

    def computeFace3(self, f):
        if self.export_uv == True:
            self.uvdic[f.vertices[0]] = [self.uvdata.data[f.index].uv[0][0], self.uvdata.data[f.index].uv[0][1]]
            self.uvdic[f.vertices[1]] = [self.uvdata.data[f.index].uv[1][0], self.uvdata.data[f.index].uv[1][1]]
            self.uvdic[f.vertices[2]] = [self.uvdata.data[f.index].uv[2][0], self.uvdata.data[f.index].uv[2][1]]

        self.ibuf.append(f.vertices[0])
        self.ibuf.append(f.vertices[1])
        self.ibuf.append(f.vertices[2])


    def computeFace4(self, f):
        if self.export_uv == True:
            self.uvdic[f.vertices[0]] = [self.uvdata.data[f.index].uv[0][0], self.uvdata.data[f.index].uv[0][1]]
            self.uvdic[f.vertices[1]] = [self.uvdata.data[f.index].uv[1][0], self.uvdata.data[f.index].uv[1][1]]
            self.uvdic[f.vertices[2]] = [self.uvdata.data[f.index].uv[2][0], self.uvdata.data[f.index].uv[2][1]]
            self.uvdic[f.vertices[3]] = [self.uvdata.data[f.index].uv[3][0], self.uvdata.data[f.index].uv[3][1]]

        self.ibuf.append(f.vertices[0])
        self.ibuf.append(f.vertices[1])
        self.ibuf.append(f.vertices[2])

        self.ibuf.append(f.vertices[0])
        self.ibuf.append(f.vertices[2])
        self.ibuf.append(f.vertices[3])

    def execute(self, context):
        f = open(self.filepath, "wb")

        for face in self.mesh.faces:
            if len(face.vertices) == 3:
                self.computeFace3(face)
            elif len(face.vertices) == 4:
                self.computeFace4(face)

        self.computeVertices()

        nvert = int(len(self.vbuf) / 3)
        
        flag = 0;
        if self.export_normals == True:
            flag = flag | 1;

        if self.export_uv == True:
            flag = flag | 2;

        data = struct.pack(">iii", nvert, len(self.ibuf), flag)

        f.write(data)

        # self.vbuf.tofile(f)
        # self.ibuf.tofile(f)
        
        f.write(struct.pack(">%df" % len(self.vbuf), *self.vbuf));
        f.write(struct.pack(">%dh" % len(self.ibuf), *self.ibuf));


        if self.export_normals == True:
            # self.nbuf.tofile(f)
            f.write(struct.pack(">%df" % len(self.nbuf), *self.nbuf));

        if self.export_uv == True:
            # self.tbuf.tofile(f)
            f.write(struct.pack(">%df" % len(self.tbuf), *self.tbuf));

        f.close()

        return {'FINISHED'}

def menu_func_export(self, context):
    self.layout.operator(ExportKfsgModel.bl_idname, text="KFSG exporter")

def register():
    bpy.utils.register_class(ExportKfsgModel)
    bpy.types.INFO_MT_file_export.append(menu_func_export)

def unregister():
    bpy.utils.unregister_class(ExportKfsgModel)
    bpy.types.INFO_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
    register()

    # test call
    bpy.ops.export.kfsg_model('INVOKE_DEFAULT')