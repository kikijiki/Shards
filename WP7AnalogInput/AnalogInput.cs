/*
Copyright (c) 2011 Matteo Bernacchia

This source is subject to the Microsoft Public License.
See http://www.microsoft.com/opensource/licenses.mspx#Ms-PL.
All other rights reserved.

THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
*/
/*
   Filename: AnalogInput.cs
    Content: Analog input game component class for WP7.
     Author: kikijiki [http://kikijiki.com]
      Notes: Read the comments or the related article in the previuos link.
Last update: 2011/05/29
  Changelog:
*/

using System;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Input.Touch;
using System.Collections.Generic;

namespace AnalogInputLibrary
{
    /// <summary>
    /// An analog control implementation that makes use of the touch input.
    /// Each one has associated a direction (versor) and an intensity (which ranges from 0 to 1).
    /// The controls can be fixed or not.
    /// In the latter case, upon the initial touch in the respective active area,
    /// it will be centered in the touch location for the duration of the movement (until release).
    /// </summary>
    public class AnalogInput : DrawableGameComponent
    {
        public interface IAnalogControl
        {
            /// <summary>
            /// If false the position is centered each time after the first touch.
            /// </summary>
            bool Fixed { get; set; }

            /// <summary>
            /// Outside this area input will be ignored for this control.
            /// </summary>
            RectF ActiveArea { get; set; }

            /// <summary>
            /// The intensity will be 1 (maximum) when the distance from the
            /// center equals the range.
            /// </summary>
            float inputRange { get; set; }

            /// <summary>
            /// If dragged after this point, the input will be lost.
            /// </summary>
            float trackRange { get; set; }

            /// <summary>
            /// The initial input must be within this range to activate the control.
            /// </summary>
            float startRange { get; set; }

            /// <summary>
            /// Position of the control.
            /// </summary>
            Vector2 Position { get; set; }

            /// <summary>
            /// Direction of the input.
            /// </summary>
            Vector2 Versor { get; }

            /// <summary>
            /// Direction of the input as a Vector3 with z=0.
            /// </summary>
            Vector3 Versor3 { get; }

            /// <summary>
            /// Input accumulator.
            /// </summary>
            Vector2 Accumulator { get; set; }

            /// <summary>
            /// Input intensity [0-1].
            /// </summary>
            float Intensity  { get; }

            /// <summary>
            /// True if the player is using the control.
            /// </summary>
            bool Pressed { get; }

            /// <summary>
            /// Transparency of the control [0-255].
            /// </summary>
            byte Alpha { get; set; }
        }

        private class AnalogControl : IAnalogControl
        {
            #region constants

            private static readonly float default_input_range = 60.0f;
            private static readonly float default_track_range = 200.0f;
            private static readonly float default_start_range = 40.0f;

            #endregion

            #region Intermediate data
            public bool is_valid = false;
            public float touch_distance = .0f;
            public Vector2? touch_position = null;
            public Vector2 touch_offset;
            #endregion

            #region Fields
            public int id = -1; //Id used to keep track of the touch input.

            //Graphics
            public Rectangle base_rect;
            public Vector2 base_center;

            public Rectangle stick_rect;
            public Vector2 stick_center;

            public Vector2 stick_position;

            public Color color = Color.White;

            //Behaviour
            public bool fixed_position = false;

            public RectF active_area;

            public float input_range = default_input_range;
            public float inv_input_range = 1.0f / default_input_range;
            public float start_range = default_start_range;
            public float track_range = default_track_range;

            //Outputs
            public Vector2? position;
            public Vector2 versor;
            public Vector3 versor3;
            public Vector2 accumulator;
            public float intensity;
            #endregion

            #region Interface implementation

            /// <summary>
            /// If set to false, the control will appear under the user touch location each time.
            /// </summary>
            public bool Fixed
            {
                get { return fixed_position; }
                set { fixed_position = value; }
            }

            /// <summary>
            /// All the input outside this area will be ignored from this control.
            /// </summary>
            public RectF ActiveArea
            {
                get { return active_area; }
                set { active_area = value; }
            }

            /// <summary>
            /// The distance for which the intensity reach the maximum value.
            /// It also influences the maximum distance where the stick gets drawn.
            /// </summary>
            public float inputRange
            {
                get { return input_range; }
                set
                {
                    if (input_range > .0f)
                    {
                        input_range = value;
                        inv_input_range = 1.0f / input_range;
                    }
                    else
                    {
                        input_range = default_input_range;
                        inv_input_range = 1.0f / input_range;
                    }
                }
            }

            /// <summary>
            /// The touch will be tracked only if it starts from within this range.
            /// </summary>
            public float startRange
            {
                get { return start_range; }
                set
                {
                    if (value > .0f)
                    {
                        start_range = value;
                    }
                    else
                    {
                        start_range = float.PositiveInfinity;
                    }
                }
            }

            /// <summary>
            /// The touch will be tracked only if it remains within this range.
            /// </summary>
            public float trackRange
            {
                get { return track_range; }
                set
                {
                    if (value > .0f)
                    {
                        start_range = value;
                    }
                    else
                    {
                        track_range = float.PositiveInfinity;
                    }
                }
            }

            /// <summary>
            /// The current position of this control. Will return the Zero vector if not set.
            /// </summary>
            public Vector2 Position
            {
                get
                {
                    if (position.HasValue)
                    {
                        return position.Value;
                    }
                    else
                    {
                        return Vector2.Zero;
                    }
                }

                set { position = new Vector2?(value); }
            }

            /// <summary>
            /// The direction of the input.
            /// </summary>
            public Vector2 Versor
            {
                get { return versor; }
                private set { versor = value; }
            }

            /// <summary>
            /// The direction of the input as a Vector3 having z = 0;
            /// </summary>
            public Vector3 Versor3
            {
                get { return versor3; }
            }

            /// <summary>
            /// Integrates the input through time.
            /// </summary>
            public Vector2 Accumulator
            {
                get { return accumulator; }
                set { accumulator = value; }
            }

            /// <summary>
            /// The intensity of the input. Ranges from 0 to 1.
            /// </summary>
            public float Intensity
            {
                get { return intensity; }
                private set { intensity = value; }
            }

            /// <summary>
            /// True if the user is using the control.
            /// </summary>
            public bool Pressed
            {
                get { return (id >= 0); }
            }

            /// <summary>
            /// Transparency of the control.
            /// </summary>
            public byte Alpha
            {
                get { return color.A; }
                set { color.A = value; }
            }
            #endregion
        }

        private SpriteBatch _sprite;

        private int _control_count = -1;
        private AnalogControl[] _control;

        private List<int> _ignore_list = new List<int>(4);

        /// <summary>
        /// Access the single controls individually.
        /// </summary>
        /// <param name="index">Index of the control.</param>
        /// <returns>The pointed control.</returns>
        public IAnalogControl this[int index]
        {
            get { return _control[index]; }
        }

        private static Texture2D _texture;

        /// <summary>
        /// The texture used by this control.
        /// </summary>
        public Texture2D Texture
        {
            get { return _texture; }
            set { _texture = value; }
        }

        public AnalogInput(Game game)
            : base(game)
        {
            game.Components.Add(this);
        }


        /// <summary>
        /// Initialize with a specified number of controls.
        /// For each control an addController() call is required for
        /// the object to work properly.
        /// </summary>
        /// <param name="texture">Texture to use to draw the control</param>
        /// <param name="controlCount">Number of controls.</param>
        public void Init(String texture, int controlCount)
        {
            _control_count = controlCount;
            _control = new AnalogControl[_control_count];

            _texture = Game.Content.Load<Texture2D>(texture);
            _sprite = Game.Services.GetService(typeof(SpriteBatch)) as SpriteBatch;

            Visible = true;
        }

        /// <summary>
        /// Initialize with 2 controls (left and right).
        /// The respective active area will default to half screen.
        /// </summary>
        /// <param name="texture">Texture to use to draw the control</param>
        /// <param name="baseRectangleLeft">Texture coordinates for this element.</param>
        /// <param name="baseCenterLeft">Texture coordinates for this element.</param>
        /// <param name="stickRectangleLeft">Texture coordinates for this element.</param>
        /// <param name="stickCenterLeft">Texture coordinates for this element.</param>
        /// <param name="baseRectangleRight">Texture coordinates for this element.</param>
        /// <param name="baseCenterRight">Texture coordinates for this element.</param>
        /// <param name="stickRectangleRight">Texture coordinates for this element.</param>
        /// <param name="stickCenterRight">Texture coordinates for this element.</param>
        public void InitTwin(
            String texture,

            Rectangle baseRectangleLeft,
            Vector2 baseCenterLeft,
            Rectangle stickRectangleLeft,
            Vector2 stickCenterLeft,

            Rectangle baseRectangleRight,
            Vector2 baseCenterRight,
            Rectangle stickRectangleRight,
            Vector2 stickCenterRight)
        {
            float width = Game.GraphicsDevice.Viewport.Width;
            float height = Game.GraphicsDevice.Viewport.Height;

            Init(texture, 2);

            addController(
                baseRectangleLeft,
                baseCenterLeft,
                stickRectangleLeft,
                stickCenterLeft,
                new RectF(.0f, .0f, width * .5f, height));

            addController(
                baseRectangleRight,
                baseCenterRight,
                stickRectangleRight,
                stickCenterRight,
                new RectF(width * .5f, .0f, width * .5f, height));
        }

        /// <summary>
        /// Add a controller. This has to be called as many times as the control count specified in the Init function.
        /// </summary>
        /// <param name="baseRectangle">Texture coordinates for this element.</param>
        /// <param name="baseCenter">Texture coordinates for this element.</param>
        /// <param name="stickRectangle">Texture coordinates for this element.</param>
        /// <param name="stickCenter">Texture coordinates for this element.</param>
        /// <param name="activeArea">Screen area interested by this controller.</param>
        /// <returns></returns>
        public int addController(
            Rectangle baseRectangle,
            Vector2 baseCenter,
            Rectangle stickRectangle,
            Vector2 stickCenter,
            RectF activeArea)
        {
            int i = 0;

            while(true)
            {
                if(i >= _control_count)
                    return -1;

                if((Object)_control[i] == null)
                    break;

                i++;
            }

            _control[i] = new AnalogControl();

            _control[i].base_rect = baseRectangle;
            _control[i].base_center = baseCenter;

            _control[i].stick_rect = stickRectangle;
            _control[i].stick_center = stickCenter;

            _control[i].active_area = activeArea;

            return i;
        }

        /// <summary>
        /// Compute position, offset and distance once to reuse it later.
        /// </summary>
        /// <param name="t">The touch location</param>
        /// <param name="id">The control id</param>
        private void computeTouch(TouchLocation t, int id)
        {
            _control[id].id = t.Id;
            _control[id].touch_position = t.Position;
            _control[id].touch_offset.X = t.Position.X - _control[id].Position.X;
            _control[id].touch_offset.Y = _control[id].Position.Y - t.Position.Y;
            _control[id].touch_distance = _control[id].touch_offset.Length();
        }

        /// <summary>
        /// Check if this touch is already tracked and eventually manage it.
        /// </summary>
        /// <param name="t">The touch location</param>
        /// <returns>True if a control is tracking this touch.</returns>
        private bool checkTrackedTouch(TouchLocation t)
        {
            for (int i = 0; i < _control_count; i++)
            {
                var c = _control[i];

                //If we're already tracking this one, use it unless it is too far.
                if (t.Id == _control[i].id)
                {
                    computeTouch(t, i);

                    if (c.touch_distance < c.track_range)
                    {
                        c.is_valid = true;
                        return true;
                    }
                    else
                    {
                        //In this case the input is lost.
                        c.is_valid = false;
                        _ignore_list.Add(t.Id);
                        return true;
                    }
                }
            }

            return false;
        }

        /// <summary>
        /// Check if this touch can be a new input for a control.
        /// </summary>
        /// <param name="t">The touch location.</param>
        /// <returns>True if a control starts to track this touch.</returns>
        private bool checkNewTouch(TouchLocation t)
        {
            for (int i = 0; i < _control_count; i++)
            {
                var c = _control[i];

                //If it's a new touch, see if it falls in the start range of an active area.
                if (c.active_area.Contains(t.Position))
                {
                    computeTouch(t, i);

                    if (c.touch_distance < c.startRange || !c.Fixed)
                    {
                        c.is_valid = true;
                        return true;
                    }
                }
            }

            return false;
        }

        /// <summary>
        /// Update the status of the controls.
        /// </summary>
        /// <param name="gameTime"></param>
        public override void Update(GameTime gameTime)
        {
            TouchCollection touches = TouchPanel.GetState();

            //Released touches are ignored no longer, but starting from next update.
            foreach (var t in touches)
            {
                if (_ignore_list.Contains(t.Id))
                {
                    if (t.State == TouchLocationState.Released)
                    {
                        _ignore_list.Remove(t.Id);
                        continue;
                    }
                    else
                    {
                        continue;
                    }
                }

                if (checkTrackedTouch(t))
                    continue;

                if (checkNewTouch(t))
                    continue;

                //Try to retrieve previous data if failed until now.
                TouchLocation earliestTouch;

                if (!t.TryGetPreviousLocation(out earliestTouch))
                {
                    if (checkNewTouch(earliestTouch))
                        continue;
                }

                //If the user touched a non active location, ignore this touch.
                _ignore_list.Add(t.Id);
            }

            for (int i = 0; i < _control_count; i++)
            {
                updateTouch(i, gameTime);
            }
        }

        /// <summary>
        /// Draw the controls.
        /// </summary>
        /// <param name="gameTime"></param>
        public override void Draw(GameTime gameTime)
        {
            if (_texture == null)
                return;

            _sprite.Begin();

            for (int i = 0; i < _control_count; i++)
            {
                drawControl(i);
            }

            _sprite.End();
        }

        /// <summary>
        /// For this control, calculate all the output values.
        /// </summary>
        /// <param name="id">Index of the control.</param>
        /// <param name="time">The game time.</param>
        private void updateTouch(int id, GameTime time)
        {
            AnalogControl c = _control[id];

            if (/*c.touch_position.HasValue &&*/ c.is_valid)
            {
                if (!c.position.HasValue)
                {
                    c.position = c.touch_position;

                    c.intensity = .0f;
                    c.versor = Vector2.Zero;
                    c.versor3 = Vector3.Zero;
                    c.stick_position = c.position.Value;
                }
                else
                {
                    if (c.touch_distance > float.Epsilon)
                    {
                        c.versor = c.touch_offset / c.touch_distance;
                        c.versor3 = new Vector3(c.versor, .0f);
                    }
                    else
                    {
                        c.versor = Vector2.Zero;
                        c.versor3 = Vector3.Zero;
                        c.touch_distance = .0f;
                    }

                    c.touch_distance = MathHelper.Min(c.input_range, c.touch_distance);
                    c.intensity = c.touch_distance * c.inv_input_range;
                    c.stick_position.X = c.position.Value.X + c.versor.X * c.touch_distance;
                    c.stick_position.Y = c.position.Value.Y - c.versor.Y * c.touch_distance;
                    c.accumulator += c.versor * (float)time.ElapsedGameTime.Milliseconds * .001f * c.intensity;
                }
            }
            else
            {
                if (!c.fixed_position)
                {
                    c.position = null;
                }
                else
                {
                    c.stick_position = c.position.Value;
                }

                c.id = -1;
                c.intensity = .0f;
                c.versor = Vector2.Zero;
            }

            c.touch_distance = .0f;
            c.touch_offset = Vector2.Zero;
            c.touch_position = null;
            c.is_valid = false;
        }

        /// <summary>
        /// Draw a single control.
        /// </summary>
        /// <param name="id">Index of the control.</param>
        private void drawControl(int id)
        {
            AnalogControl c = _control[id];

            if (c.id >= 0 || c.fixed_position)
            {
                _sprite.Draw(_texture, c.position.Value - c.base_center, c.base_rect, c.color);
                _sprite.Draw(_texture, c.stick_position - c.stick_center, c.stick_rect, c.color);
            }
        }

        /// <summary>
        /// Reset all accumulators.
        /// </summary>
        public void ResetAccumulators()
        {
            for(int i = 0; i < _control_count; i++)
            {
                _control[i].accumulator.X = _control[i].accumulator.Y = .0f;
            }
        }
    }
}
