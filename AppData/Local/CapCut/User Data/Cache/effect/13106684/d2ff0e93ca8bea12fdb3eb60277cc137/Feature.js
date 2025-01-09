const Amaz = effect.Amaz;

class Feature
{
    onInit()
    {
        this.scene = null;
    }

    onLoadScenes(...scenes)
    {
        this.scene = scenes[0];
    }

    onUnloadScenes()
    {
        this.scene = null;
    }
   
    onSetParameter(name, value)
    {
    }
   
    onGetParameter(name)
    {
    }
   
    onBeforeAlgorithmUpdate(graphName)
    {
        var algorithm = Amaz.AmazingManager.getSingleton("Algorithm");

        if (this.scene)
        {
            if (this.scene.getSceneOETF() == 1 || this.scene.getSceneOETF() == 2)
            {
                algorithm.setAlgorithmParamStr(graphName, "vhdr_0", "execParam", "enhanceStrength=1.0&luminanceTarget=200");
            }
            else
            {
                algorithm.setAlgorithmParamStr(graphName, "vhdr_0", "execParam", "enhanceStrength=1.0&luminanceTarget=250");
            }
        }
    }

    onAfterAlgorithmUpdate(graphName)
    {
    }
}

exports.Feature = Feature;