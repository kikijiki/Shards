using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Input.Touch;
using Microsoft.Xna.Framework.Media;
using AnalogInputLibrary;

namespace AnalogInputTest
{
    public class TestGame : Microsoft.Xna.Framework.Game
    {
        GraphicsDeviceManager graphics;
        SpriteBatch spriteBatch;
        SpriteFont default_spritefont;
        AnalogInput ai;

        public TestGame()
        {
            graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";

            TargetElapsedTime = TimeSpan.FromTicks(333333);
        }

        protected override void Initialize()
        {
            base.Initialize();
        }

        protected override void LoadContent()
        {
            spriteBatch = new SpriteBatch(GraphicsDevice);
            Services.AddService(typeof(SpriteBatch), spriteBatch);

            default_spritefont = Content.Load<SpriteFont>(@"Font\default");

            ai = new AnalogInput(this);

            ai.InitTwin(
                @"Textures/analog",
                new Rectangle(0, 0, 128, 128), new Vector2(64.0f, 64.0f),
                new Rectangle(128, 0, 40, 40), new Vector2(20.0f, 20.0f),
                new Rectangle(0, 128, 128, 128), new Vector2(64.0f, 64.0f),
                new Rectangle(128, 128, 40, 40), new Vector2(20.0f, 20.0f));

            ai[0].Fixed = true;
            ai[0].Position = new Vector2(80, 400);
        }

        protected override void UnloadContent()
        {
        }

        protected override void Update(GameTime gameTime)
        {
            if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed)
                this.Exit();

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.CornflowerBlue);

            spriteBatch.Begin();

            spriteBatch.DrawString(
                default_spritefont, 
                "Intensity: " + ai[0].Intensity.ToString("f2"), 
                new Vector2(10.0f, 10.0f),
                Color.Black);

            spriteBatch.DrawString(
                default_spritefont, 
                "Direction: (" + ai[0].Versor.X.ToString("f2") + "," + ai[0].Versor.Y.ToString("f2") + ")", 
                new Vector2(10.0f, 40.0f), 
                Color.Black);

            spriteBatch.DrawString(
                default_spritefont,
                "Accumulator: (" + ai[0].Accumulator.X.ToString("f2") + "," + ai[0].Accumulator.Y.ToString("f2") + ")",
                new Vector2(10.0f, 70.0f),
                Color.Black);

            spriteBatch.DrawString(
                default_spritefont,
                "Intensity: " + ai[1].Intensity.ToString("f2"),
                new Vector2(400.0f, 10.0f),
                Color.Black);

            spriteBatch.DrawString(
                default_spritefont,
                "Direction: (" + ai[1].Versor.X.ToString("f2") + "," + ai[1].Versor.Y.ToString("f2") + ")",
                new Vector2(400.0f, 40.0f),
                Color.Black);

            spriteBatch.DrawString(
                default_spritefont,
                "Accumulator: (" + ai[1].Accumulator.X.ToString("f2") + "," + ai[1].Accumulator.Y.ToString("f2") + ")",
                new Vector2(400.0f, 70.0f),
                Color.Black);

            spriteBatch.End();

            base.Draw(gameTime);
        }
    }
}
