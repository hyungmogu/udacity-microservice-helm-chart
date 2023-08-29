import os
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())

class KubernetesSetupTool:
    def prepare_manifest(self):
        base_paths = [os.path.join("./.kubernetes", folder) for folder in os.listdir("./.kubernetes") if "_src" not in folder]
        env_variables = {
            "DB_PASSWORD": os.environ.get("KUBERNETES_POSTGRES_PASSWORD", ""),
        }

        # Create folder ".circleci/kubernetes/base_src" if it doesn't exist
        for base_path in base_paths:
            output_path = base_path + "_src"
            if not os.path.exists(output_path):
                os.makedirs(output_path)

            # for each file in .circleci/kubernetes folder with .example.yaml extension,
            # replace the placeholder starting with $ with the value from env_variables
            for file in os.listdir(base_path):
                if file.endswith(".yaml.example"):
                    with open("{}/{}".format(base_path, file), "r") as f:
                        content = f.read()

                    for key, value in env_variables.items():
                        content = content.replace("${}".format(key), str(value))

                    with open("{}/{}.yaml".format(output_path, file.split(".")[0]), "w+") as f:
                        f.write(content)

    def run(self):
        self.prepare_manifest()


if __name__ == "__main__":
    setup_tool = KubernetesSetupTool()
    setup_tool.run()