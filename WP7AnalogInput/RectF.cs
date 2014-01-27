using Microsoft.Xna.Framework;

namespace AnalogInputLibrary
{
    public struct RectF
    {
        private float _x;
        private float _y;
        private float _width;
        private float _height;

        public RectF(float x, float y, float width, float height)
        {
            _x = x;
            _y = y;
            _width = width;
            _height = height;
        }

        public bool Contains(Vector2 pt)
        {
            return ((((_x <= pt.X) && (pt.X < (_x + _width))) && (_y <= pt.Y)) && (pt.Y < (_y + _height)));
        }
    }
}